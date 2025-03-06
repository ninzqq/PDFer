import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pdfer/src/utils/pdf_view.dart';
import 'package:pdfer/src/utils/save_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class DeleteView extends StatefulWidget {
  const DeleteView({super.key, required this.files});

  final List<File> files;

  @override
  State<DeleteView> createState() => _DeleteViewState();
}

class _DeleteViewState extends State<DeleteView> {
  @override
  Widget build(BuildContext context) {
    TextEditingController pageNumberController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Type in the page number you want to delete from your PDF document',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final context = this.context;
                  await saveFile(widget.files[0].path).then((value) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'File saved to "/storage/emulated/0/Download/output.pdf"'),
                      ),
                    );
                    Logger().d(
                        'File saved to "/storage/emulated/0/Download/output.pdf"');
                  });

                  // Delete the temporary file
                  final tempDirectory = await getTemporaryDirectory();
                  final tempPath = '${tempDirectory.path}/output.pdf';
                  await File(tempPath).delete().then((value) {
                    Logger().d('Temporary file deleted');
                  });
                },
                icon: const Icon(Icons.save),
                tooltip: 'Save',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: TextField(
                    controller: pageNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Page number',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: () {
                    if (pageNumberController.text.isNotEmpty) {
                      _deletePage(int.parse(pageNumberController.text));
                    }
                  },
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete page'),
            ],
          ),
          const SizedBox(height: 16),
          PdfView(file: widget.files[0]),
        ],
      ),
    );
  }

  Future<void> _deletePage(int pageNumber) async {
    //Load the existing PDF document.
    final PdfDocument document =
        PdfDocument(inputBytes: File(widget.files[0].path).readAsBytesSync());

    if (pageNumber > document.pages.count) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Page number must not exceed the number of pages in the document (${document.pages.count})'),
        ),
      );
      Logger()
          .e('Page number is greater than the number of pages in the document');
      return;
    } else if (pageNumber < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Page number must be greater than 0'),
        ),
      );
      Logger().e('Page number is less than 1');
      return;
    }

    //Remove the page from the document.
    document.pages.removeAt(pageNumber - 1);

    //Save the document.
    final tempDirectory = await getTemporaryDirectory();
    final outputPath = '${tempDirectory.path}/output.pdf';
    await File(outputPath).writeAsBytes(await document.save()).then((value) {
      Logger().d('Page deleted. New file saved to $outputPath');
      setState(() {
        widget.files[0] = File(outputPath);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Page deleted.'),
        ),
      );
    });

    //Dispose the document.
    document.dispose();
  }
}
