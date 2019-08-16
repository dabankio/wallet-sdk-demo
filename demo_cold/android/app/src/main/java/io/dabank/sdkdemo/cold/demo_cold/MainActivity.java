package io.dabank.sdkdemo.cold.demo_cold;

import android.os.Bundle;

import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import mobile.Mobile;
import geth.Geth;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "walletcore/eth";

    private static Long argument2long(Object argument) {
        if (argument == null) {
            throw new RuntimeException("argument is null");

        }
        if (argument instanceof Integer) {
            return ((Integer) argument).longValue();
        } else if (argument instanceof Long) {
            return (Long) argument;
        } else {
            throw new RuntimeException("argument is not integer or long," + argument.toString());
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, Result result) {
                System.out.println(CHANNEL + ":" + call.method + ",arguments:" + call.arguments);

                try {

                    switch (call.method) {
                        case "genEthKey": {
                            String prvk = (String) call.arguments;
                            String key = geth.Geth.utilGenKey(prvk);
                            result.success(key);
                            break;
                        }
                        case "buildTime": {
                            String bt = mobile.Mobile.getBuildTime();
                            result.success(bt);
                            break;
                        }
                        case "packedDeploySimpleMultiSig": {
                            Integer sigRequired = call.argument("sigRequired");
                            Long chainId = argument2long(call.argument("chainId"));
                            List<String> addrs = call.argument("addrs");
                            geth.AddressesWrap wrapAddrs = new geth.AddressesWrap();
                            for (String addr : addrs) {
                                wrapAddrs.addOne(new geth.ETHAddress(addr));
                            }

                            byte[] data = Geth.packedDeploySimpleMultiSig(new geth.BigInt(new Long(sigRequired)), wrapAddrs, new geth.BigInt(chainId));
                            result.success(data);
                            break;
                        }
                        case "newETHTransactionForContractCreationAndSign": {
                            System.out.println("newETHTransactionForContractCreationAndSign invoked");

                            Integer nonce = call.argument("nonce");
                            Long gasLimit = argument2long(call.argument("gasLimit"));
                            Long gasPrice = argument2long(call.argument("gasPrice"));
                            byte[] data = call.argument("data");
                            String prvkey = call.argument("prvkey");

                            geth.ETHTransaction tx = new geth.ETHTransaction(nonce.longValue(), gasLimit, new geth.BigInt(gasPrice), data);
                            String encodedRlp = tx.encodeRLP();

                            geth.Signer signer = new geth.Signer();
                            String signed = signer.sign(encodedRlp, prvkey);
                            result.success(signed);
                            break;
                        }
                        case "newTransactionAndSign": {
                            System.out.println("newTransactionAndSign invoked");

                            Integer nonce = call.argument("nonce");
                            Long gasLimit = argument2long(call.argument("gasLimit"));
                            Long gasPrice = argument2long(call.argument("gasPrice"));
                            byte[] data = call.argument("data");
                            String prvkey = call.argument("prvkey");
                            Double amount = call.argument("amount");
                            String toAddress = call.argument("toAddress");

                            geth.ETHTransaction tx = new geth.ETHTransaction(nonce.longValue(), new geth.ETHAddress(toAddress), new geth.BigInt(amount.longValue()), gasLimit, new geth.BigInt(gasPrice), data);
                            String encodedRlp = tx.encodeRLP();

                            geth.Signer signer = new geth.Signer();
                            String signed = signer.sign(encodedRlp, prvkey);
                            result.success(signed);
                            break;
                        }
                        case "signMultisigExecute": {
//                            'prvkey': prvk,
//                            'multisigContractAddress': call.multisigContractAddress,
//                            'toAddress': call.toAddress,
//                            'internalNonce': call.internalNonce,
//                            'amount': call.amount,
//                            'gasLimit': call.gasLimit,
//                            'data': call.data

                            String prvkey = call.argument("prvkey");
                            String multisigContractAddress = call.argument("multisigContractAddress");
                            String toAddress = call.argument("toAddress");
                            Long internalNonce = argument2long(call.argument("internalNonce"));
                            Double amount = call.argument("amount");
                            Long gasLimit = argument2long(call.argument("gasLimit"));
                            String executorAddress = call.argument("executor");
                            byte[] data = call.argument("data");
                            Long chainId = argument2long(call.argument("chainId"));

                            geth.SimpleMultiSigExecuteSignResult ret = geth.Geth.utilSimpleMultiSigExecuteSign(chainId, prvkey, multisigContractAddress, toAddress, executorAddress, internalNonce, new geth.BigInt(amount.longValue()), new geth.BigInt(gasLimit), data);
                            result.success(ret.toHex());
                            break;
                        }
                        default:
                            result.success("unknown method");
                    }

                } catch (Exception e) {
                    System.err.println(e);
                    e.printStackTrace();
//                    e.printStackTrace(new PrintStream(System.out));
                }
            }
        });

    }
}
