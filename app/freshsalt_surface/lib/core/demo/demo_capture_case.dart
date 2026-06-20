class DemoCaptureCase {
  const DemoCaptureCase({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sampleId,
    required this.baselineImagePath,
    required this.saltedImagePath,
    required this.imageMetadata,
  });

  final String id;
  final String title;
  final String subtitle;
  final String sampleId;
  final String baselineImagePath;
  final String saltedImagePath;
  final Map<String, dynamic> imageMetadata;
}
