package io.dabank.sdkdemo.demo_watch;

import java.util.List;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import geth.SimpleMultiSigABIHelper;
import geth.SimpleMultiSigExecuteSignResult;
import geth.Uint8ArrayWrap;
import geth.Byte32ArrayWrap;
import geth.SizedByteArray;
import geth.ETHAddress;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "walletcore/eth";
  
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
                  case "simpleMultisigAbiPackedNonce": {
                    SimpleMultiSigABIHelper helper = new SimpleMultiSigABIHelper();
                    byte[] ret = helper.packedNonce();
                    result.success(ret);
                    break;
                  }
                  case "simpleMultisigAbiUnpackedNonce": {
                    byte[] resp = call.arguments();
                    SimpleMultiSigABIHelper helper = new SimpleMultiSigABIHelper();
                    geth.BigInt bigInt = helper.unpackNonce(resp);
                    Long nonce = bigInt.getInt64();
                    result.success(nonce);
                    break;
                  }
                  case "simpleMultisigPackedExecute": {
                    String toAddress = call.argument("toAddress");
                    Double amount = call.argument("amount");
                    byte[] data = call.argument("data");
                    Integer gasLimit = call.argument("gasLimit");
                    List<String> sigs = call.argument("sigs"); //需要根据address按照升序排好
                    String executorAddr = call.argument("executor");
                    ETHAddress executor = new ETHAddress(executorAddr); //此处为空地址

                    Uint8ArrayWrap sigVs = new Uint8ArrayWrap();
                    Byte32ArrayWrap sigRs = new Byte32ArrayWrap();
                    Byte32ArrayWrap sigSs = new Byte32ArrayWrap();
                    
                    for (int i = 0; i< sigs.size(); i++) {
                      String sig = sigs.get(i);
                      SimpleMultiSigExecuteSignResult re = new SimpleMultiSigExecuteSignResult(sig);
                      SizedByteArray r = re.getR();
                      SizedByteArray s = re.getS();
                      sigVs.addOne(re.getV());
                      sigRs.addOne(re.getR().get());
                      sigSs.addOne(re.getS().get());
                    }
                    SimpleMultiSigABIHelper helper = new SimpleMultiSigABIHelper();
                    byte[] packedExecuteData = helper.packedExecute(sigVs, sigRs, sigSs, new ETHAddress(toAddress), new geth.BigInt(amount.longValue()), data, executor, new geth.BigInt(gasLimit.longValue()));
                    result.success(packedExecuteData);
                    // System.out.println(packedExecuteData);
                    break;
                  }
                  default:
                      throw new RuntimeException("unknown channel method");
              }

          } catch (Exception e) {
              System.err.println(e);
              e.printStackTrace();
          }
      }
  });
  }
}
