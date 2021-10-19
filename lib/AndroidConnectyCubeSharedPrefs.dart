import 'package:path_provider/path_provider.dart';

class AndroidConnectyCubeSharedPrefs{

  void readFile() async{
    var datadir = await getApplicationSupportDirectory();
    print('===========================');
    print(datadir.path);
  }

}