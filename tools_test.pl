#!/usr/local/bin/perl
use Db::Documentum qw (:all);
use Db::Documentum::Tools qw (:all);

dm_Connect("docb1","docb1own","docb1own");

## 1

print "\n\nTest 1...This will create a document in your default cabinet named 'test_doc'\n";
print "(Should succeed.)\n";
undef %ATTRS;
%ATTRS = (object_name =>  ['test_doc1'],
          title       =>  ['My Test Doc 1'],
          authors     =>  ['Scott 1','Scott 2'],
          keywords    =>  ['Scott','Test','Doc','1'],
          r_version_label => ['TEST']);
$doc_id = dm_CreateObject ("dm_document",%ATTRS);

if ($doc_id) {
   print "doc_id = $doc_id\n";
   dmAPIExec("save,c,$doc_id");
}
else {
    print "No Doc ID returned.\n";
   print "ERRORS: " . dm_LastError("c,1") . "\n";
}

## 2

print "\n\nTest 2...No attribute named 'name' for dm_document (Should fail.)\n";
undef %ATTRS;
%ATTRS = (name        =>  ['test_doc2'],
          title       =>  ['My Test Doc 2'],
          authors     =>  ['Scott 1','Scott 2'],
          keywords    =>  ['Scott','Test','Doc','2'],
          r_version_label => ['TEST']);                               
$doc_id = dm_CreateObject ("dm_document",%ATTRS);

if ($doc_id) {
   print "doc_id = $doc_id\n";
   dmAPIExec("save,c,$doc_id");
}
else {
   print "No Doc ID returned.\n";
   print "ERRORS: " . dm_LastError("c,1") . "\n";
}

## 3

print "\n\nTest 3...This should succeed but will set title = 'My Test Doc 3-2'.\n";
undef %ATTRS;
%ATTRS = (object_name =>  ['test_doc3'],
          title       =>  ['My Test Doc 3','My Test Doc 3-2'],
          authors     =>  ['Scott 1','Scott 2'],
          keywords    =>  ['Scott','Test','Doc','2'],
          r_version_label => ['TEST']);
$doc_id = dm_CreateObject ("dm_document",%ATTRS);

if ($doc_id) {
   print "doc_id = $doc_id\n";
   dmAPIExec("save,c,$doc_id");
}
else {
   print "No Doc ID returned.\n";
   print "ERRORS: " . dm_LastError("c,1") . "\n"; 
}

## 4

print "\n\nTest 4...Create new type, my_document based upon dm_document\n";
undef %ATTRS;
%ATTRS = (cat_id   =>  'CHAR(16)',
          locale =>  'CHAR(255) REPEATING');
$doc_id = dm_CreateType ("my_document","dm_document",%ATTRS);

if ($doc_id) {
    print "OK\n";
}
else {
   print "Failed\n";
   print "ERRORS: " . dm_LastError("c,1") . "\n";
}

## 5

print "\n\nTest 5...Create new type, your_document, based upon my_document with no additional attributes.\n";
$doc_id = dm_CreateType ("your_document","my_document");
if ($doc_id) {
   print "OK\n";
}
else {
   print "Failed\n";
   print "ERRORS: " . dm_LastError("c,1") . "\n";
}

## 6

print "\n\nTest 6...This should succeed if you have an my_document subtype of dm_document\n";
undef %ATTRS;
%ATTRS = (object_name =>  ['test_doc4'],
          title       =>  ['My Test Doc 4'],
          authors     =>  ['Scott 1','Scott 2'],
          keywords    =>  ['Scott','Test','Doc','4'],
          r_version_label => ['TEST'],
          locale      =>  ['1','2','3']);
$doc_id = dm_CreateObject ("my_document",%ATTRS);
if ($doc_id) {
   print "doc_id = $doc_id\n";
   dmAPIExec("save,c,$doc_id");
}
else {
   print "No Doc ID returned.\n";  
   print "ERRORS: " . dm_LastError("c,1") . "\n";
}

print "\n\nDone.\n";
exit;

