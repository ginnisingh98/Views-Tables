--------------------------------------------------------
--  DDL for Package Body PA_PCO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PCO_PKG" as
/* $Header: PAPCORPB.pls 120.2.12010000.1 2009/07/20 10:03:14 sosharma noship $ */

/*
 Procedure      : create_fnd_attachment
 Type           : Public
 Purpose        : This procedure first checks for the existance of a record in FND_LOBS for the passed primary_key values.
                  In this case, p_CR_id and p_CR_version_number form the primary key.
                  If a record is found, then only the data in FND_LOBS is deleted, and reinserted with empty_blob.
                  In case match is not found, an additional step is performed to insert data into fnd_documents and fnd_attached_documents
                  also. This is done by calling fnd_attached_documents_pkg.Insert_Row.

 Parameters              Type  Required   Description and Purpose
 ==========              ====  ========   =======================
 p_doc_category_name   VARCHAR   YES      identifier in FND_LOBS
 p_entity_name         VARCHAR   YES      identifier in FND_LOBS
 p_file_name           VARCHAR   YES      Name of the attachment
 p_file_content_type   VARCHAR   YES      Content type of the attachment
 p_CR_id               VARCHAR   YES      primary key 1 value (Change req id)
 p_CR_version_number   VARCHAR   YES      primary key 1 value (Version number)
 p_file_id             NUMBER     NO      file_id in FND_LOBS
 */


procedure create_fnd_attachment
      (
      p_doc_category_name      varchar,
      p_entity_name            varchar,
      p_file_name              fnd_lobs.file_name%type,
      p_file_content_type      fnd_lobs.file_content_type%type,
      p_CR_id                  varchar,
      p_CR_version_number      varchar,
      p_file_id  IN OUT nocopy number)
      is


x_Rowid                varchar2(100);
x_document_id          number;
x_media_id             number;
l_attached_document_id number;


l_blob_data            blob;
l_category_id          number;
l_entity_name          varchar2(100);

l_doc_category_name    varchar2(100);
l_file_name            fnd_lobs.file_name%type;
l_file_content_type    fnd_lobs.file_content_type%type;
l_call_Insert_Row      boolean := False;


begin

pa_debug.debug('100: Inside create_fnd_attachment');

/* sosharma The doc_category_name parameters are redundant now as we would be storing the attachments with category_id = 1 */
-- l_doc_category_name :=p_doc_category_name;
l_entity_name := p_entity_name;
l_file_name := p_file_name;
l_file_content_type := p_file_content_type;
l_blob_data := empty_blob();


 /*  sosharma
 Commented as per change in implementation
 SELECT category_id
    into l_category_id
    from fnd_document_categories
    where name = l_doc_category_name;*/


l_category_id := 1;

   pa_debug.debug('200: Calling get_attachment_file_id ');

    get_attachment_file_id
        (p_entity_name,
         p_CR_id,
         p_CR_version_number,
         null,
         null,
         null,
         p_file_id);

/* if p_file_id is returned as Null, it means attachments have not been created for this version of the change request.
   Next value of X_media_id is derived, and l_call_Insert_Row is set to True to invoke fnd_attached_documents_pkg.Insert_Row to insert
   new records into fnd_documents and fnd_attached_documents.

   Otherwise p_file_id conatins the file_id of the existing attachment, which is then deleted and record is inserted only into FND_LOBS.
*/
    if p_file_id is null then

        SELECT fnd_lobs_s.nextval
        INTO X_media_id
        FROM dual;

         l_call_Insert_Row := TRUE;
    else

    /*  delete the existing attachment from fnd_lobs */

       delete from fnd_lobs
       where file_id = p_file_id;

        X_media_id := p_file_id;
        l_call_Insert_Row := False;

    end if;


    pa_debug.debug('300: x_media_id:' || x_media_id || ', l_file_name:' || l_file_name);

       INSERT INTO fnd_lobs (
            file_id
          , File_name
          , file_content_type
          , upload_date
          , expiration_date
          , program_name
          , program_tag
          , file_data
          , language
          , oracle_charset
          , file_format)
          VALUES
          ( x_media_id
          , l_file_name
          , l_file_content_type
          , sysdate
          , null
          , 'PA_PCO_REPORT'
          , null
          , l_blob_data
          , null
          , null
          , 'binary');

     pa_debug.debug('400: After Insertion into fnd_lobs ');

     select fnd_attached_documents_s.nextval
     into l_attached_document_id
     from dual;


 /*  l_call_Insert_Row would be true only if its the first call for this version of the change request to create an attachment.
    Only in that case, there is a need to insert records into fnd_documents and fnd_attached_documents
 */
     if (l_call_Insert_Row) then
        pa_debug.debug('500: Calling fnd_attached_documents_pkg.Insert_Row');

        fnd_attached_documents_pkg.Insert_Row(
                      X_Rowid                      =>  X_Rowid
                    , X_attached_document_id       =>  l_attached_document_id
                    , X_document_id                =>  X_document_id
                    , X_creation_date              =>  SYSDATE
                    , X_created_by                 =>  1
                    , X_last_update_date           =>  SYSDATE
                    , X_last_updated_by            =>  1
                    , X_last_update_login          =>  1
                    , X_seq_num                    =>  10
                    , X_entity_name                =>  l_entity_name
                    , X_column1                    =>  NULL
                    , X_pk1_value                  =>  p_CR_id
                    , X_pk2_value                  =>  p_CR_version_number
                    , X_pk3_value                  =>  NULL
                    , X_pk4_value                  =>  NULL
                    , X_pk5_value                  =>  NULL
                    , X_automatically_added_flag   =>  'N'
                  /*  columns necessary for creating a document on the fly */
                 , X_datatype_id                    => 6
                 , X_category_id                    => l_category_id
                 , X_security_type                  => 1
                 , X_publish_flag                   => 'Y'
                 , X_usage_type                     => 'S'
                 , X_language                       => NULL
                 , X_media_id                       => X_media_id
                 , X_doc_attribute_Category         =>  NULL
                 , X_doc_attribute1                 =>  NULL
                 , X_doc_attribute2                 =>  NULL
                 , X_doc_attribute3                 =>  NULL
                 , X_doc_attribute4                 =>  NULL
                 , X_doc_attribute5                 =>  NULL
                 , X_doc_attribute6                 =>  NULL
                 , X_doc_attribute7                 =>  NULL
                 , X_doc_attribute8                 =>  NULL
                 , X_doc_attribute9                 =>  NULL
                 , X_doc_attribute10                =>  NULL
                 , X_doc_attribute11                =>  NULL
                 , X_doc_attribute12                =>  NULL
                 , X_doc_attribute13                =>  NULL
                 , X_doc_attribute14                =>  NULL
                 , X_doc_attribute15                =>  NULL
                  );

        pa_debug.debug('600: After call to fnd_attached_documents_pkg.Insert_Row ');

   else
        pa_debug.debug('700: Attachment records exist already, so not creating fresh records ');
   end if;

     p_file_id := x_media_id;

exception
when others then
 p_file_id := null;
    pa_debug.debug('700: In exception block...');
    pa_debug.debug('SQLERRM:' || SQLERRM || ', SQLCODE:' || SQLCODE);
end create_fnd_attachment;



/*
 Procedure      : get_attachment_file_id
 Type           : Public
 Purpose        : This procedure returns the file_id of the FND attachment. It accepts the primary key values
                  and then checks for existence in fnd_documents and fnd_attached_documents.

 Parameters      Type   Required     Description and Purpose
 ==========      ====   ========     =======================
 p_entity_name  NUMBER    YES        identifier in FND_LOBS
 p_pk1_value    NUMBER    YES        Primary key 1 (Change req id)
 p_pk2_value    NUMBER    YES        Primary key 2 (Version Number)
 p_pk3_value    NUMBER    NO         Primary key 3
 p_pk4_value    NUMBER    NO         Primary key 4
 p_pk5_value    NUMBER    NO         Primary key  5
 p_file_id      NUMBER    NO         file_id in FND_LOBS
 */

procedure get_attachment_file_id
         (p_entity_name      IN  varchar2,
          p_pk1_value        IN  varchar2 default NULL,
          p_pk2_value        IN  varchar2 default NULL,
          p_pk3_value        IN  varchar2 default NULL,
          p_pk4_value        IN  varchar2 default NULL,
          p_pk5_value        IN  varchar2 default NULL,
          p_file_id          IN OUT nocopy number) is

          l_file_id    number;

begin

        pa_debug.debug('Inside get_attachment_file_id...');

        select media_id
        into l_file_id
        from fnd_documents doc,
             fnd_attached_documents ad
        where ad.document_id = doc.document_id
          and ad.entity_name = p_entity_name
          and nvl(ad.pk1_value,'-99')   = nvl(p_pk1_value,nvl(ad.pk1_value,'-99'))
          and nvl(ad.pk2_value,'-99')   = nvl(p_pk2_value,nvl(ad.pk2_value,'-99'))
          and nvl(ad.pk3_value,'-99')   = nvl(p_pk3_value,nvl(ad.pk3_value,'-99'))
          and nvl(ad.pk4_value,'-99')   = nvl(p_pk4_value,nvl(ad.pk4_value,'-99'))
          and nvl(ad.pk5_value,'-99')   = NVL(p_pk5_value,nvl(ad.pk5_value,'-99'));

          pa_debug.debug('10: l_file_id = ' || l_file_id);
          p_file_id := l_file_id;

exception
   when no_data_found then
        p_file_id := null;
        pa_debug.debug('20: returning null l_file_id');

end get_attachment_file_id;

end PA_PCO_PKG;

/
