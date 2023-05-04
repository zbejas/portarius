/*
    Data for the container configuration
*/
class ContainerConfig {
  bool attachStderr;
  bool attachStdin;
  bool attachStdout;
  List<String> cmd;
  List<String> env;
  String domain;
  String hostname;
  String image;
  bool openStdin;
  bool stdinOnce;
  bool tty;
  String user;
  String workingDir;
  Map<String, dynamic> volumes;

  ContainerConfig({
    required this.attachStderr,
    required this.attachStdin,
    required this.attachStdout,
    required this.cmd,
    required this.env,
    required this.hostname,
    required this.image,
    required this.openStdin,
    required this.stdinOnce,
    required this.tty,
    required this.user,
    required this.workingDir,
    required this.volumes,
    required this.domain,
  });

  factory ContainerConfig.fromJson(Map<String, dynamic> data) {
    return ContainerConfig(
      attachStderr: data['AttachStderr'] as bool,
      attachStdin: data['AttachStdin'] as bool,
      attachStdout: data['AttachStdout'] as bool,
      cmd: List<String>.from((data['Cmd'] ?? []) as List<dynamic>),
      env: List<String>.from((data['Env'] ?? []) as List<dynamic>),
      hostname: data['Hostname'] as String,
      image: data['Image'] as String,
      openStdin: data['OpenStdin'] as bool,
      stdinOnce: data['StdinOnce'] as bool,
      tty: data['Tty'] as bool,
      user: data['User'] as String,
      workingDir: data['WorkingDir'] as String,
      volumes: data['Volumes'] == null
          ? {}
          : Map<String, dynamic>.from(data['Volumes'] as Map<String, dynamic>),
      domain: data['Domainname'] as String,
    );
  }
}
