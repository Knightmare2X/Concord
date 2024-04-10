import 'package:flutter/material.dart';
class UploadSong extends StatefulWidget {
  const UploadSong({Key? key}) : super(key: key);

  @override
  State<UploadSong> createState() => _UploadSongState();
}

class _UploadSongState extends State<UploadSong> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: /*_file == null ?*/ _buildUploadButton() /*: _buildSongPreview()*/,
    );
  }

  Widget _buildUploadButton() {
    return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    //albumart
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Upload Albumart',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    //song
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Upload Song',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    //performed by
                    ItemInputField(),
                    SizedBox(height: 20,),
                    //written by
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Upload Song',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    //prooduced by
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Upload Song',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    //upload button
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 2, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Upload Song',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 20, // Text size
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


            ],
          ),
        ));
  }


}

class ItemInputField extends StatefulWidget {
  @override
  _ItemInputFieldState createState() => _ItemInputFieldState();
}

class _ItemInputFieldState extends State<ItemInputField> {
  final TextEditingController _textEditingController = TextEditingController();
  List<String> _items = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: 'Enter Item',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _items.add(_textEditingController.text);
                    _textEditingController.clear();
                  });
                },
              ),
            ),
            onSubmitted: (value) {
              setState(() {
                _items.add(value);
                _textEditingController.clear();
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_items[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _items.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}