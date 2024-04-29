--------------------------------------------------------
--  DDL for Package Body DOM_ATTACHMENT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_ATTACHMENT_UTIL_PKG" AS
/* $Header: DOMAUTLB.pls 120.13 2006/09/20 19:03:30 sabatra noship $ */
/*---------------------------------------------------------------------------+
 | This package contains public APIs for  Attachments functionality          |
 +---------------------------------------------------------------------------*/

G_WEBSERVICES                 VARCHAR2(80) :=  'WEBSERVICES';
----------------------------------------------------------------
--Private: sync_dom_file_ext
----------------------------------------------------------------
procedure sync_dom_file_ext
(
  p_repository_id   IN number
  ,p_version_id     IN number
  ,p_status         IN varchar2
)
IS

BEGIN
 update dom_file_ext
 set status =p_status
 where repository_id=p_repository_id
 and version_id=p_version_id;
 IF ( SQL%NOTFOUND ) THEN
   insert into dom_file_ext
   (
     repository_id
     ,version_id
     ,status
   )
   values
   (
     p_repository_id
     ,p_version_id
     ,p_status
   );
 END IF;

END sync_dom_file_ext;
----------------------------------------------------------------------


Procedure Attach (
   p_Document_id               IN Number
  , p_Entity_name              IN Varchar2
  , p_Pk1_value                IN Varchar2
  , p_Pk2_value                IN Varchar2 DEFAULT NULL
  , p_Pk3_value                IN Varchar2 DEFAULT NULL
  , p_Pk4_value                IN Varchar2 DEFAULT NULL
  , p_Pk5_value                IN Varchar2 DEFAULT NULL
  , p_category_id              IN Number
  , p_created_by               IN Number
  , p_last_update_login        IN Number DEFAULT NULL
  , x_Attached_document_id     OUT NOCOPY Number
)
IS


l_document_id         number;
l_row_id              VARCHAR2(2000);
l_category_id         NUMBER;
l_created_by          NUMBER;
l_entity_name         VARCHAR2(40);
l_pk1_value           VARCHAR2(100);
l_pk2_value           VARCHAR2(100);
l_pk3_value           VARCHAR2(100);
l_pk4_value           VARCHAR2(100);
l_pk5_value           VARCHAR2(100);
l_last_update_login   NUMBER;
l_media_id            NUMBER;
l_attached_document_id NUMBER;
BEGIN
  l_document_id:=p_Document_id;


  -- SBAG: When Attach action is called, the attached_document_id
  -- will be null. So the id is created out of the sequence number
  -- to pass to fnd_attached_documents_pkg.insert_row api.

  select fnd_attached_documents_s.nextval
    into l_attached_document_id from dual;

  fnd_attached_documents_pkg.Insert_Row(
           X_Rowid                      => l_row_id,
           X_attached_document_id       => l_Attached_document_id,
           X_document_id                => l_document_id,
           X_creation_date              => sysdate,
           X_created_by                 => p_created_by,
           X_last_update_date           => sysdate,
           X_last_updated_by            => p_created_by,
           X_last_update_login          => p_last_update_login,
           X_seq_num                    => 1,
           X_entity_name                => p_entity_name,
           X_column1                    => null,
           X_pk1_value                  => p_pk1_value,
           X_pk2_value                  => p_pk2_value,
           X_pk3_value                  => p_pk3_value,
           X_pk4_value                  => p_pk4_value,
           X_pk5_value                  => p_pk5_value,
           X_automatically_added_flag   => 'N',
           X_datatype_id                => null,
           X_category_id                => p_category_id,
           X_security_type              => null,
           X_publish_flag               => null,
           X_usage_type                 => null,
           X_language                   => null,
           X_media_id                   => l_media_id,
           X_doc_attribute_Category     => null,
           X_doc_attribute1             => null,
           X_doc_attribute2             => null,
           X_doc_attribute3             => null,
           X_doc_attribute4             => null,
           X_doc_attribute5             => null,
           X_doc_attribute6             => null,
           X_doc_attribute7             => null,
           X_doc_attribute8             => null,
           X_doc_attribute9             => null,
           X_doc_attribute10            => null,
           X_doc_attribute11            => null,
           X_doc_attribute12            => null,
           X_doc_attribute13            => null,
           X_doc_attribute14            => null,
           X_doc_attribute15            => null,
           X_create_doc                 => 'N' -- Fix for 3762710
         );
   x_Attached_document_id:=l_Attached_document_id;

END Attach;
----------------------------------------------------------------------

Procedure Create_Attachment (
    p_Document_id               IN Number
  , p_Entity_name              IN Varchar2
  , p_Pk1_value                IN Varchar2
  , p_Pk2_value                IN Varchar2 DEFAULT NULL
  , p_Pk3_value                IN Varchar2 DEFAULT NULL
  , p_Pk4_value                IN Varchar2 DEFAULT NULL
  , p_Pk5_value                IN Varchar2 DEFAULT NULL
  , p_category_id              IN Number
  , p_repository_id	       IN NUMBER
  , p_version_id	       IN NUMBER
  , p_family_id		       IN NUMBER
  , p_file_name		       IN VARCHAR2
  , p_created_by               IN NUMBER
  , p_last_update_login        IN NUMBER DEFAULT NULL
  , x_Attached_document_id     OUT NOCOPY NUMBER
)
IS


l_document_id         number;
l_row_id              VARCHAR2(2000);
l_category_id         NUMBER;
l_created_by          NUMBER;
l_entity_name         VARCHAR2(40);
l_pk1_value           VARCHAR2(100);
l_pk2_value           VARCHAR2(100);
l_pk3_value           VARCHAR2(100);
l_pk4_value           VARCHAR2(100);
l_pk5_value           VARCHAR2(100);
l_last_update_login   NUMBER;
l_media_id            NUMBER;
l_attached_document_id NUMBER;
l_language	      VARCHAR2(10);
l_dm_document_id      NUMBER;
BEGIN
  l_document_id:=p_Document_id;


  -- SBAG: When Attach action is called, the attached_document_id
  -- will be null. So the id is created out of the sequence number
  -- to pass to fnd_attached_documents_pkg.insert_row api.

  select fnd_attached_documents_s.nextval
    into l_attached_document_id from dual;

  if ( l_document_id is null ) THEN

	SELECT fnd_documents_s.nextval
	INTO l_document_id
	FROM dual;

	l_category_id := p_category_id;
	l_media_id := p_family_id;

	INSERT INTO fnd_documents(
	 document_id,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 datatype_id,
	 category_id,
	 security_type,
	 publish_flag,
	 usage_type,
         media_id,
	 dm_document_id,
         file_name,
	 dm_node,
	 dm_type)
	VALUES (
	 l_document_id,
	 sysdate,
	 p_created_by,
	 sysdate,
	 p_created_by,
	 p_last_update_login,
	 8,
	 l_category_id,
	 4,
	 'Y',
	 0,
         p_family_id,
	 p_version_id,
	 p_file_name,
	 p_repository_id,
	 'FILE');

	 SELECT userenv('LANG') INTO l_language FROM dual;

	 fnd_documents_pkg.insert_tl_row(
		 X_document_id => l_document_id,
		 X_creation_date     => sysdate,
		 X_created_by        => p_created_by,
		 X_last_update_date  => sysdate,
		 X_last_updated_by   => p_created_by,
		 X_last_update_login => p_last_update_login,
		 X_language          => l_language
	 );

  else

	 INSERT INTO fnd_documents
		(document_id,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		datatype_id,
		category_id,
		security_type,
		publish_flag,
		usage_type,
		media_id,
		dm_document_id,
		file_name,
		dm_node,
		dm_type)
        SELECT
		fnd_documents_s.NEXTVAL,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		datatype_id,
		category_id,
		security_type,
		publish_flag,
		usage_type,
		media_id,
		decode(dm_document_id,0,p_version_id,dm_document_id),
		file_name,
		dm_node,
		dm_type
        FROM fnd_documents x
        WHERE x.document_id = l_document_id;

	select media_id, category_id, userenv('LANG') into l_media_id, l_category_id, l_language from fnd_documents where document_id = l_document_id;

	select fnd_documents_s.CURRVAL into l_document_id from dual;

	fnd_documents_pkg.insert_tl_row(
		 X_document_id => l_document_id,
		 X_creation_date     => sysdate,
		 X_created_by        => p_created_by,
		 X_last_update_date  => sysdate,
		 X_last_updated_by   => p_created_by,
		 X_last_update_login => p_last_update_login,
		 X_language          => l_language
	 );




  end if;

  fnd_attached_documents_pkg.Insert_Row(
     X_Rowid                      => l_row_id,
     X_attached_document_id       => l_Attached_document_id,
     X_document_id                => l_document_id,
     X_creation_date              => sysdate,
     X_created_by                 => p_created_by,
     X_last_update_date           => sysdate,
     X_last_updated_by            => p_created_by,
     X_last_update_login          => p_last_update_login,
     X_seq_num                    => 1,
     X_entity_name                => p_entity_name,
     X_column1                    => null,
     X_pk1_value                  => p_pk1_value,
     X_pk2_value                  => p_pk2_value,
     X_pk3_value                  => p_pk3_value,
     X_pk4_value                  => p_pk4_value,
     X_pk5_value                  => p_pk5_value,
     X_automatically_added_flag   => 'N',
     X_datatype_id                => null,
     X_category_id                => l_category_id,
     X_security_type              => null,
     X_publish_flag               => null,
     X_usage_type                 => null,
     X_language                   => null,
     X_media_id                   => l_media_id,
     X_doc_attribute_Category     => null,
     X_doc_attribute1             => null,
     X_doc_attribute2             => null,
     X_doc_attribute3             => null,
     X_doc_attribute4             => null,
     X_doc_attribute5             => null,
     X_doc_attribute6             => null,
     X_doc_attribute7             => null,
     X_doc_attribute8             => null,
     X_doc_attribute9             => null,
     X_doc_attribute10            => null,
     X_doc_attribute11            => null,
     X_doc_attribute12            => null,
     X_doc_attribute13            => null,
     X_doc_attribute14            => null,
     X_doc_attribute15            => null,
     X_create_doc                 => 'N' -- Fix for 3762710
   );

   UPDATE fnd_attached_documents set category_id = l_category_id where attached_document_id = l_Attached_document_id;

   x_Attached_document_id:=l_Attached_document_id;

END Create_Attachment;
----------------------------------------------------------------------

Procedure Detach(
    p_Attached_document_id      IN Number
)
IS
cursor get_document_id
  is
  select att.document_id,docs.datatype_id
    from fnd_attached_documents att,
    fnd_documents docs
    where Attached_document_id=p_Attached_document_id
    and docs.document_id=att.document_id;


cursor check_other_attachments (cp_document_id number)
IS
SELECT attached_document_id
    FROM fnd_attached_documents
    where document_id=cp_document_id;


  l_document_id  number;
  l_dummy  NUMBER;
  l_datatype_id  number;

BEGIN
   open get_document_id;
   fetch get_document_id INTO
          l_document_id,l_datatype_id;
   CLOSE get_document_id;

   delete fnd_attached_documents
   where attached_document_id = p_Attached_document_id;

   open check_other_attachments (l_document_id);
   fetch check_other_attachments INTO l_dummy;
   CLOSE check_other_attachments;
   if( l_dummy is  null) THEN
     fnd_documents_pkg.Delete_Row(
        X_document_id   =>l_document_id,
        X_datatype_id   =>l_datatype_id,
        delete_ref_Flag => 'Y');
   END if;


END Detach;
----------------------------------------------------------------------



/* This will be called after the MODIFY action */
Procedure Update_Document(
     p_Attached_document_id     IN Number
    , p_FileName                IN Varchar2
    , p_Description             IN Varchar2 DEFAULT NULL
    , p_Category                IN Number
    , p_last_updated_by         IN Number
    , p_last_update_login       IN Number DEFAULT NULL
)
IS

  cursor get_document_id(cp_Attached_document_id number)
  is
  select document_id
    from fnd_attached_documents
    where Attached_document_id=p_Attached_document_id;
  l_document_id  number;

BEGIN

   open get_document_id (p_Attached_document_id);
   fetch get_document_id INTO
          l_document_id;
   CLOSE get_document_id;



  update fnd_documents_tl
  set  Description = p_Description
      ,last_updated_by = p_last_updated_by
      ,last_update_login =p_last_update_login
  where document_id= l_document_id
  and language=userenv('LANG');

  update fnd_documents
  set File_Name = p_FileName
     ,Category_id= p_Category
      ,last_updated_by = p_last_updated_by
      ,last_update_login =p_last_update_login
  where document_id= l_document_id;

  update fnd_attached_documents
  set Category_id= p_Category
    ,last_updated_by = p_last_updated_by
    ,last_update_login =p_last_update_login
  where Attached_document_id=p_Attached_document_id;

END Update_Document;
----------------------------------------------------------------------


/* To be called for change attach version */
Procedure Change_Version(
     p_Attached_document_id      IN Number
   , p_Document_id               IN Number
   , p_last_updated_by           IN Number
   , p_last_update_login         IN Number DEFAULT NULL
)

IS

BEGIN
  UPDATE fnd_attached_documents
	   SET document_id = p_Document_id,
	   last_update_date = sysdate,
	   last_updated_by = p_last_updated_by,
	   last_update_login = p_last_update_login
	   WHERE attached_document_id = p_Attached_document_id;
END Change_Version;
----------------------------------------------------------------------

/* This procedure is after approval / review to change fnd document
status */
Procedure Change_Status(
     p_Attached_document_id      IN Number
   , p_Document_id               IN Number
   , p_Repository_id             IN Number
   , p_Status                    IN Varchar2
   , p_submitted_by              IN Number
   , p_last_updated_by           IN Number
   , p_last_update_login         IN Number DEFAULT NULL
)
IS

l_service_url   		VARCHAR2(255);
l_return_status	    VARCHAR2(10);
l_msg_count		      NUMBER;
l_msg_data		      VARCHAR2(2000);
l_user_name         VARCHAR2(255);
l_Repository_id     NUMBER;
l_repos_type        VARCHAR(80);

cursor get_serivce_url(cp_Repository_id number)
IS
select service_url
from dom_repositories
where id=cp_Repository_id;

cursor get_user_name(cp_user_id number)
IS
select user_name
from fnd_user
where user_id=cp_user_id;

CURSOR get_affected_attachments(cp_dm_document_id NUMBER)
IS
select att.attached_document_id
from fnd_attached_documents att,
fnd_documents docs
where docs.document_id=att.document_id
and docs.dm_document_id=cp_dm_document_id;

CURSOR is_WebServices_document(cp_Repository_id NUMBER)
IS
SELECT n.protocol
from dom_repositories n
where n.id=cp_Repository_id;


BEGIN
  l_Repository_id:=p_Repository_id;
  IF(p_Repository_id is null) THEN
    l_Repository_id:=0;
  END IF;

  OPEN is_WebServices_document(l_Repository_id);
  FETCH is_WebServices_document into l_repos_type;
  CLOSE is_WebServices_document;
	--dbms_output.put_line('Repos type='||l_repos_type);
  IF(l_repos_type =G_WEBSERVICES  AND p_Document_id is NOT  null ) THEN

   sync_dom_file_ext(p_Repository_id,p_Document_id,p_Status);

  /*
  	open get_user_name(p_submitted_by);
	  fetch get_user_name into l_user_name;
	  close get_user_name;

	  open get_serivce_url(p_Repository_id);
	  fetch get_serivce_url into l_service_url;
	  close get_serivce_url;
	  --call jsp   with p_Document_id,p_Status, service url, p_submitted_by
	  DOM_WS_INTERFACE_PUB.Update_Files_Document_Status
	  (
	    p_api_version	      => 1.0,
      p_service_url       => l_service_url,
      p_document_id      	=> p_Document_id,
      p_status           	=> p_Status,
      p_login_user_name   => l_user_name,
      x_return_status	    => l_return_status,
      x_msg_count		      => l_msg_count,
      x_msg_data		      => l_msg_data
	  );
	  */

	  --Update status for all the attached documents for the WS document.
	  FOR rec in get_affected_attachments(p_Document_id) LOOP
	    --dbms_output.put_line('Updating attachment id= '||rec.attached_document_id);
	    UPDATE fnd_attached_documents
	    SET status = p_Status,
	    last_update_date = sysdate,
	    last_updated_by = p_submitted_by,
	    last_update_login = p_last_update_login
	    WHERE attached_document_id = rec.attached_document_id;
	  END LOOP;
  END IF;

  IF( p_Attached_document_id IS NOT NULL) THEN
    --Update status for Non-WebServices document
    UPDATE fnd_attached_documents
    SET status = p_Status,
    last_update_date = sysdate,
    last_updated_by = p_submitted_by,
    last_update_login = p_last_update_login
    WHERE attached_document_id = p_Attached_document_id;
	END iF;

	--EXCEPTION
	  --WHEN OTHERS THEN

END Change_Status;
----------------------------------------------------------------------
FUNCTION get_repos_doc_view_url
 (
    p_document_id      IN  NUMBER
  )RETURN VARCHAR2
  IS
  l_document_access_url      VARCHAR2(800);
  l_document_path            VARCHAR2(500);
  l_host_url                 VARCHAR2(200);
  l_media_id                 NUMBER;
  l_datatype_id              NUMBER;
  l_encrypt_key varchar2(30):='DM$Param'||'&'||'Key';
  cursor get_doc_info (cp_document_id number)
  IS
   select media_id,datatype_id
   from fnd_documents_vl
   where document_id=cp_document_id;

  BEGIN

    OPEN  get_doc_info (p_document_id);
    fetch get_doc_info  INTO l_media_id,l_datatype_id;
    close get_doc_info;

    if(l_datatype_id =8 OR l_datatype_id =9) THEN
      l_document_access_url:=fnd_profile.value('APPS_FRAMEWORK_AGENT')||'/OA.jsp?page=/oracle/apps/dom/dmrepository/webui/DomSelfSecuredRenderPG'||'&'||'retainAM=Y';
      l_document_access_url:=l_document_access_url||'&'||'DOM_PARAM_DOCUMENT_ID='||fnd_web_sec.encrypt(l_encrypt_key,p_document_id);
      l_document_access_url:=l_document_access_url||'&'||'DOM_PARAM_MEDIA_ID='||fnd_web_sec.encrypt(l_encrypt_key,l_media_id);
      l_document_access_url:=l_document_access_url||'&'||'DOM_PARAM_DATATYPE_ID='||fnd_web_sec.encrypt(l_encrypt_key,l_datatype_id);
      return  l_document_access_url;
    END IF;

    IF(l_datatype_id =7) THEN
	    SELECT  repos.dav_url,
	    docs.dm_folder_path||'/'||docs.file_name
	    INTO l_host_url,l_document_path
	    FROM fnd_documents_vl docs,
	    dom_repositories repos
	    where repos.id=docs.dm_node
	    and docs.document_id=p_document_id;

	    l_document_path:=wfa_html.conv_special_url_chars(l_document_path);
	    l_document_path:=replace(l_document_path,'%2F','/');
	    IF(substr(l_document_path,0,1) <> '/') THEN
	      l_document_path:='/'||l_document_path;
	    END IF;

	    l_document_access_url:=l_host_url||l_document_path;
	    RETURN l_document_access_url;
	  END IF;

END get_repos_doc_view_url;
-------------------------------------------------------------------

PROCEDURE delete_attachments(X_entity_name IN VARCHAR2,
		X_pk1_value IN VARCHAR2,
		X_pk2_value IN VARCHAR2 DEFAULT NULL,
		X_pk3_value IN VARCHAR2 DEFAULT NULL,
		X_pk4_value IN VARCHAR2 DEFAULT NULL,
		X_pk5_value IN VARCHAR2 DEFAULT NULL,
		X_delete_document_flag IN VARCHAR2,
		X_automatically_added_flag IN VARCHAR2 DEFAULT NULL) IS
l_delete_document_flag varchar2(1);
BEGIN
fnd_attached_documents2_pkg.delete_attachments(X_entity_name,
		X_pk1_value,
		X_pk2_value,
		X_pk3_value,
		X_pk4_value,
		X_pk5_value,
		X_delete_document_flag,
		X_automatically_added_flag);

END delete_attachments;




PROCEDURE copy_documents(X_from_document_id IN OUT NOCOPY NUMBER,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL) IS
  l_delete_document_flag varchar2(1);
CURSOR docpk1 IS
	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fad.category_id att_cat, fad.pk2_value, fad.pk3_value,
                fad.pk4_value, fad.pk5_value,
		fd.datatype_id, fd.category_id, fd.security_type, fd.security_id,
		fd.publish_flag, fd.image_type, fd.storage_type,
		fd.usage_type, fd.start_date_active, fd.end_date_active,
		fdtl.language, fdtl.description, fd.file_name,
		fd.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15, fd.url, fdtl.title  ,
    FD.DM_NODE fd_dm_node,
        fd.DM_FOLDER_PATH fd_DM_FOLDER_PATH,
        fd.DM_TYPE fd_DM_TYPE,
        fd.DM_DOCUMENT_ID fd_DM_DOCUMENT_ID,
        fd.DM_VERSION_NUMBER fd_DM_VERSION_NUMBER,
        fd.URL fd_URL,
        fd.MEDIA_ID fd_MEDIA_ID
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE	fad.document_id = fd.document_id
	    AND fd.document_id = fdtl.document_id
	    AND fdtl.language  = userenv('LANG')
	    AND fd.document_id = X_from_document_id  ;

  CURSOR shorttext (mid NUMBER) IS
	SELECT short_text
	  FROM fnd_documents_short_text
	 WHERE media_id = mid;

   CURSOR longtext (mid NUMBER) IS
	SELECT long_text
	  FROM fnd_documents_long_text
	 WHERE media_id = mid;

   CURSOR fnd_lobs_cur (mid NUMBER) IS
        SELECT file_id,
               file_name,
               file_content_type,
               upload_date,
               expiration_date,
               program_name,
               program_tag,
               file_data,
               language,
               oracle_charset,
               file_format
        FROM fnd_lobs
        WHERE file_id = mid;

   media_id_tmp NUMBER;
   document_id_tmp NUMBER;
   row_id_tmp VARCHAR2(30);
   short_text_tmp VARCHAR2(4000);
   long_text_tmp LONG;
   docrec docpk1%ROWTYPE;
   fnd_lobs_rec fnd_lobs_cur%ROWTYPE;
BEGIN
	--  Use cursor loop to get all attachments associated with


          OPEN docpk1;
          FETCH docpk1 INTO docrec;
    --FOR docrec IN doclist LOOP
		--  One-Time docs that Short Text or Long Text will have
		--  to be copied into a new document (Long Text will be
		--  truncated to 32K).  Create the new document records
		--  before creating the attachment record
		--
		IF (docrec.usage_type = 'O'
		    AND docrec.datatype_id IN (1,2,5,6,7,8,9) ) THEN
			--  Create Documents records
			FND_DOCUMENTS_PKG.Insert_Row(row_id_tmp,
		                document_id_tmp,
				SYSDATE,
				NVL(X_created_by,0),
				SYSDATE,
				NVL(X_created_by,0),
				X_last_update_login,
				docrec.datatype_id,
				NVL(X_to_category_id, docrec.category_id),
				docrec.security_type,
				docrec.security_id,
				docrec.publish_flag,
				docrec.image_type,
				docrec.storage_type,
				docrec.usage_type,
				docrec.start_date_active,
				docrec.end_date_active,
				X_request_id,
				X_program_application_id,
				X_program_id,
				SYSDATE,
				docrec.language,
				docrec.description,
				docrec.file_name,
				media_id_tmp,
				docrec.dattr_cat, docrec.dattr1,
				docrec.dattr2, docrec.dattr3,
				docrec.dattr4, docrec.dattr5,
				docrec.dattr6, docrec.dattr7,
				docrec.dattr8, docrec.dattr9,
				docrec.dattr10, docrec.dattr11,
				docrec.dattr12, docrec.dattr13,
				docrec.dattr14, docrec.dattr15,
                                'N',docrec.url, docrec.title);

			--  overwrite document_id from original
			--  cursor for later insert into
			--  fnd_attached_documents

			docrec.document_id := document_id_tmp;

      IF(docrec.datatype_id =7 OR docrec.datatype_id =8 OR docrec.datatype_id =9)
      then
      UPDATE fnd_documents
      SET
        DM_NODE = docrec.fd_dm_node,
         DM_FOLDER_PATH =docrec.fd_dm_folder_path,
         DM_TYPE = docrec.fd_dm_type,
         DM_DOCUMENT_ID = docrec.fd_dm_document_id,
         DM_VERSION_NUMBER = docrec.fd_dm_version_number,
         URL = docrec.fd_url,
         MEDIA_ID = docrec.fd_media_id
      WHERE
      document_id = document_id_tmp;
      END IF;     --end of update the document row for ws/webdav attachments


			--  Duplicate short or long text
			IF (docrec.datatype_id = 1) THEN
				--  Handle short Text
				--  get original data
				OPEN shorttext(docrec.media_id);
				FETCH shorttext INTO short_text_tmp;
				CLOSE shorttext;

				INSERT INTO fnd_documents_short_text (
					media_id,
					short_text)
				 VALUES (
					media_id_tmp,
					short_text_tmp);
			media_id_tmp := '';

			ELSIF (docrec.datatype_id = 2) THEN
				--  Handle long text
				--  get original data
				OPEN longtext(docrec.media_id);
				FETCH longtext INTO long_text_tmp;
				CLOSE longtext;

				INSERT INTO fnd_documents_long_text (
					media_id,
					long_text)
				 VALUES (
					media_id_tmp,
					long_text_tmp);
			media_id_tmp := '';

		        ELSIF (docrec.datatype_id=6) THEN

                         OPEN fnd_lobs_cur(docrec.media_id);
                         FETCH fnd_lobs_cur
                           INTO fnd_lobs_rec.file_id,
                                fnd_lobs_rec.file_name,
                                fnd_lobs_rec.file_content_type,
                                fnd_lobs_rec.upload_date,
                                fnd_lobs_rec.expiration_date,
                                fnd_lobs_rec.program_name,
                                fnd_lobs_rec.program_tag,
                                fnd_lobs_rec.file_data,
                                fnd_lobs_rec.language,
                                fnd_lobs_rec.oracle_charset,
                                fnd_lobs_rec.file_format;
                         CLOSE fnd_lobs_cur;

             INSERT INTO fnd_lobs (
                                 file_id,
                                 file_name,
                                 file_content_type,
                                 upload_date,
                                 expiration_date,
                                 program_name,
                                 program_tag,
                                 file_data,
                                 language,
                                 oracle_charset,
                                 file_format)
               VALUES  (
                       media_id_tmp,
                       fnd_lobs_rec.file_name,
                       fnd_lobs_rec.file_content_type,
                       fnd_lobs_rec.upload_date,
                       fnd_lobs_rec.expiration_date,
                       fnd_lobs_rec.program_name,
                       fnd_lobs_rec.program_tag,
                       fnd_lobs_rec.file_data,
                       fnd_lobs_rec.language,
                       fnd_lobs_rec.oracle_charset,
                       fnd_lobs_rec.file_format);

                       media_id_tmp := '';

		  END IF;  -- end of duplicating text


		END IF;   --  end if usage_type = 'O' and datatype in (1,2,6)

	--  Update the document to be a std document if it
	--  was an ole or image that wasn't already a std doc
	--  (images should be created as Std, but just in case)
		IF (docrec.datatype_id IN (3,4)
		    AND docrec.usage_type <> 'S') THEN
			UPDATE fnd_documents
			   SET usage_type = 'S'
			WHERE document_id = docrec.document_id;
		END IF;

 --  end of working through all attachments
--  close cursors.


         CLOSE docpk1;


       EXCEPTION WHEN OTHERS THEN
       -- need to close all cursors
       CLOSE docpk1;
       CLOSE shorttext;
       CLOSE longtext;
       CLOSE fnd_lobs_cur;

END copy_documents ;


PROCEDURE copy_attachments_fnd(X_from_entity_name IN VARCHAR2,
			X_from_pk1_value IN VARCHAR2,
			X_from_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk5_value IN VARCHAR2 DEFAULT NULL,
      X_from_attachment_id IN NUMBER DEFAULT NULL,
			X_to_entity_name IN VARCHAR2,
			X_to_pk1_value IN VARCHAR2,
			X_to_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk5_value IN VARCHAR2 DEFAULT NULL,
      X_to_attachment_id IN OUT NOCOPY NUMBER,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL) IS

  CURSOR docpk1 IS
	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fad.category_id att_cat, fad.pk2_value, fad.pk3_value,
                fad.pk4_value, fad.pk5_value,
		fd.datatype_id, fd.category_id, fd.security_type, fd.security_id,
		fd.publish_flag, fd.image_type, fd.storage_type,
		fd.usage_type, fd.start_date_active, fd.end_date_active,
		fdtl.language, fdtl.description, fd.file_name,
		fd.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15, fd.url, fdtl.title,
 FD.DM_NODE fd_dm_node,
        fd.DM_FOLDER_PATH fd_DM_FOLDER_PATH,
        fd.DM_TYPE fd_DM_TYPE,
        fd.DM_DOCUMENT_ID fd_DM_DOCUMENT_ID,
        fd.DM_VERSION_NUMBER fd_DM_VERSION_NUMBER,
        fd.URL fd_URL,
        fd.MEDIA_ID fd_MEDIA_ID

	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE	fd.document_id = fad.document_id
	    AND fdtl.document_id = fd.document_id
      AND fdtl.language  = userenv('LANG')
	    AND fad.entity_name = X_from_entity_name
	    AND fad.pk1_value = X_from_pk1_value
	    AND (X_from_category_id IS NULL
		 OR (fad.category_id = X_from_category_id
		 OR (fad.category_id is NULL AND fd.category_id = X_from_category_id)))
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag)
     AND (X_from_attachment_id IS NULL OR fad.attached_document_id = X_from_attachment_id);


CURSOR docpk2 IS
	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fad.category_id att_cat, fad.pk2_value, fad.pk3_value,
                fad.pk4_value, fad.pk5_value,
		fd.datatype_id, fd.category_id, fd.security_type, fd.security_id,
		fd.publish_flag, fd.image_type, fd.storage_type,
		fd.usage_type, fd.start_date_active, fd.end_date_active,
		fdtl.language, fdtl.description, fd.file_name,
		fd.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15, fd.url, fdtl.title,
    FD.DM_NODE fd_dm_node,
        fd.DM_FOLDER_PATH fd_DM_FOLDER_PATH,
        fd.DM_TYPE fd_DM_TYPE,
        fd.DM_DOCUMENT_ID fd_DM_DOCUMENT_ID,
        fd.DM_VERSION_NUMBER fd_DM_VERSION_NUMBER,
        fd.URL fd_URL,
        fd.MEDIA_ID fd_MEDIA_ID
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE	fd.document_id = fad.document_id
	    AND fdtl.document_id = fd.document_id
      AND fdtl.language  = userenv('LANG')
	    AND fad.entity_name = X_from_entity_name
	    AND fad.pk1_value = X_from_pk1_value
	    AND fad.pk2_value = X_from_pk2_value
	    AND (X_from_category_id IS NULL
		 OR (fad.category_id = X_from_category_id
		 OR (fad.category_id is NULL AND fd.category_id = X_from_category_id)))
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag)
     AND (X_from_attachment_id IS NULL OR fad.attached_document_id = X_from_attachment_id);





CURSOR docpk3 IS
	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fad.category_id att_cat, fad.pk2_value, fad.pk3_value,
                fad.pk4_value, fad.pk5_value,
		fd.datatype_id, fd.category_id, fd.security_type, fd.security_id,
		fd.publish_flag, fd.image_type, fd.storage_type,
		fd.usage_type, fd.start_date_active, fd.end_date_active,
		fdtl.language, fdtl.description, fd.file_name,
		fd.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15, fd.url, fdtl.title ,
    FD.DM_NODE fd_dm_node,
        fd.DM_FOLDER_PATH fd_DM_FOLDER_PATH,
        fd.DM_TYPE fd_DM_TYPE,
        fd.DM_DOCUMENT_ID fd_DM_DOCUMENT_ID,
        fd.DM_VERSION_NUMBER fd_DM_VERSION_NUMBER,
        fd.URL fd_URL,
        fd.MEDIA_ID fd_MEDIA_ID
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE	fd.document_id = fad.document_id
	    AND fdtl.document_id = fd.document_id
	    AND fdtl.language  = userenv('LANG')
	    AND fad.entity_name = X_from_entity_name
	    AND fad.pk1_value = X_from_pk1_value
	    AND fad.pk2_value = X_from_pk2_value
            AND fad.pk3_value = X_from_pk3_value
--	    AND (X_from_category_id IS NULL
--		 OR (fad.category_id = X_from_category_id
--		 OR (fad.category_id is NULL AND fd.category_id = X_from_category_id)))
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag)
     AND (X_from_attachment_id IS NULL OR fad.attached_document_id = X_from_attachment_id);





CURSOR doclist IS
	SELECT fad.seq_num, fad.document_id,
		fad.attribute_category, fad.attribute1, fad.attribute2,
		fad.attribute3, fad.attribute4, fad.attribute5,
		fad.attribute6, fad.attribute7, fad.attribute8,
		fad.attribute9, fad.attribute10, fad.attribute11,
		fad.attribute12, fad.attribute13, fad.attribute14,
		fad.attribute15, fad.column1, fad.automatically_added_flag,
		fad.category_id att_cat, fad.pk2_value, fad.pk3_value,
                fad.pk4_value, fad.pk5_value,
		fd.datatype_id, fd.category_id, fd.security_type, fd.security_id,
		fd.publish_flag, fd.image_type, fd.storage_type,
		fd.usage_type, fd.start_date_active, fd.end_date_active,
		fdtl.language, fdtl.description, fd.file_name,
		fd.media_id, fdtl.doc_attribute_category dattr_cat,
		fdtl.doc_attribute1 dattr1, fdtl.doc_attribute2 dattr2,
		fdtl.doc_attribute3 dattr3, fdtl.doc_attribute4 dattr4,
		fdtl.doc_attribute5 dattr5, fdtl.doc_attribute6 dattr6,
		fdtl.doc_attribute7 dattr7, fdtl.doc_attribute8 dattr8,
		fdtl.doc_attribute9 dattr9, fdtl.doc_attribute10 dattr10,
		fdtl.doc_attribute11 dattr11, fdtl.doc_attribute12 dattr12,
		fdtl.doc_attribute13 dattr13, fdtl.doc_attribute14 dattr14,
		fdtl.doc_attribute15 dattr15, fd.url, fdtl.title,
    FD.DM_NODE fd_dm_node,
        fd.DM_FOLDER_PATH fd_DM_FOLDER_PATH,
        fd.DM_TYPE fd_DM_TYPE,
        fd.DM_DOCUMENT_ID fd_DM_DOCUMENT_ID,
        fd.DM_VERSION_NUMBER fd_DM_VERSION_NUMBER,
        fd.URL fd_URL,
        fd.MEDIA_ID fd_MEDIA_ID
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl
	  WHERE		fd.document_id = fad.document_id
	    AND fdtl.document_id = fd.document_id
	    AND fdtl.language  = userenv('LANG')
	    AND fad.entity_name = X_from_entity_name
	    AND fad.pk1_value = X_from_pk1_value
	    AND (X_from_pk2_value IS NULL
		 OR fad.pk2_value = X_from_pk2_value)
	    AND (X_from_pk3_value IS NULL
		 OR fad.pk3_value = X_from_pk3_value)
	    AND (X_from_pk4_value IS NULL
		 OR fad.pk4_value = X_from_pk4_value)
	    AND (X_from_pk5_value IS NULL
		 OR fad.pk5_value = X_from_pk5_value)
	    AND (X_from_category_id IS NULL
		 OR (fad.category_id = X_from_category_id
		 OR (fad.category_id is NULL AND fd.category_id = X_from_category_id)))
	    AND fad.automatically_added_flag like decode(X_automatically_added_flag,NULL,'%',X_automatically_added_flag)
     AND (X_from_attachment_id IS NULL OR fad.attached_document_id = X_from_attachment_id);





   CURSOR shorttext (mid NUMBER) IS
	SELECT short_text
	  FROM fnd_documents_short_text
	 WHERE media_id = mid;

   CURSOR longtext (mid NUMBER) IS
	SELECT long_text
	  FROM fnd_documents_long_text
	 WHERE media_id = mid;

   CURSOR fnd_lobs_cur (mid NUMBER) IS
        SELECT file_id,
               file_name,
               file_content_type,
               upload_date,
               expiration_date,
               program_name,
               program_tag,
               file_data,
               language,
               oracle_charset,
               file_format
        FROM fnd_lobs
        WHERE file_id = mid;

   media_id_tmp NUMBER;
   document_id_tmp NUMBER;
   row_id_tmp VARCHAR2(30);
   short_text_tmp VARCHAR2(4000);
   long_text_tmp LONG;
   docrec doclist%ROWTYPE;
   fnd_lobs_rec fnd_lobs_cur%ROWTYPE;
   l_to_attachment_id NUMBER;
   l_something VARCHAR2(2000);
BEGIN
	--  Use cursor loop to get all attachments associated with
	--  the from_entity
  	IF (X_from_entity_name IS NULL OR X_from_pk1_value IS NULL) THEN
    RETURN;
        END IF;

        IF    X_from_pk2_value IS NULL THEN -- performance change IF
          OPEN docpk1;
        ELSIF X_from_pk3_value IS NULL THEN
          OPEN docpk2;
        ELSIF X_from_pk4_value IS NULL THEN
          OPEN docpk3;
        ELSE
          OPEN doclist;
        END IF;
        <<pkloop>>
        LOOP

          IF    X_from_pk2_value IS NULL THEN -- performance change IF
           FETCH docpk1 INTO docrec;
           --EXIT
           IF (docpk1%notfound) THEN
              EXIT pkloop;

           END IF;
          ELSIF X_from_pk3_value IS NULL THEN
           FETCH docpk2 INTO docrec;
           IF (docpk2%notfound) THEN
              EXIT pkloop;

           END IF;
          ELSIF X_from_pk4_value IS NULL THEN
           FETCH docpk3 INTO docrec;
           IF (docpk3%notfound) THEN
              EXIT pkloop;

           END IF;
          ELSE
           FETCH doclist INTO docrec;
           IF (doclist%notfound) THEN
                       EXIT pkloop;

           END IF;
          END IF;

                --FOR docrec IN doclist LOOP
		--  One-Time docs that Short Text or Long Text will have
		--  to be copied into a new document (Long Text will be
		--  truncated to 32K).  Create the new document records
		--  before creating the attachment record
		--
		IF (docrec.usage_type = 'O'
		    AND docrec.datatype_id IN (1,2,5,6,7,8,9) ) THEN
			--  Create Documents records
			FND_DOCUMENTS_PKG.Insert_Row(row_id_tmp,
		                document_id_tmp,
				SYSDATE,
				NVL(X_created_by,0),
				SYSDATE,
				NVL(X_created_by,0),
				X_last_update_login,
				docrec.datatype_id,
				NVL(X_to_category_id, docrec.category_id),
				docrec.security_type,
				docrec.security_id,
				docrec.publish_flag,
				docrec.image_type,
				docrec.storage_type,
				docrec.usage_type,
				docrec.start_date_active,
				docrec.end_date_active,
				X_request_id,
				X_program_application_id,
				X_program_id,
				SYSDATE,
				docrec.language,
				docrec.description,
				docrec.file_name,
				media_id_tmp,
				docrec.dattr_cat, docrec.dattr1,
				docrec.dattr2, docrec.dattr3,
				docrec.dattr4, docrec.dattr5,
				docrec.dattr6, docrec.dattr7,
				docrec.dattr8, docrec.dattr9,
				docrec.dattr10, docrec.dattr11,
				docrec.dattr12, docrec.dattr13,
				docrec.dattr14, docrec.dattr15,
                                'N',docrec.url, docrec.title);

			--  overwrite document_id from original
			--  cursor for later insert into
			--  fnd_attached_documents

      --update the document row for ws/webdav attachments
      IF(docrec.datatype_id =7 OR docrec.datatype_id =8 OR docrec.datatype_id =9)
      then
      UPDATE fnd_documents
      SET
        DM_NODE = docrec.fd_dm_node,
         DM_FOLDER_PATH =docrec.fd_dm_folder_path,
         DM_TYPE = docrec.fd_dm_type,
         DM_DOCUMENT_ID = docrec.fd_dm_document_id,
         DM_VERSION_NUMBER = docrec.fd_dm_version_number,
         URL = docrec.fd_url,
         MEDIA_ID = docrec.fd_media_id
      WHERE
      document_id = document_id_tmp;
      END IF;     --end of update the document row for ws/webdav attachments
			docrec.document_id := document_id_tmp;
			--  Duplicate short or long text

      IF (docrec.datatype_id = 1) THEN
				--  Handle short Text
				--  get original data
				OPEN shorttext(docrec.media_id);
				FETCH shorttext INTO short_text_tmp;
				CLOSE shorttext;

				INSERT INTO fnd_documents_short_text (
					media_id,
					short_text)
				 VALUES (
					media_id_tmp,
					short_text_tmp);
			media_id_tmp := '';

			ELSIF (docrec.datatype_id = 2) THEN
				--  Handle long text
				--  get original data
				OPEN longtext(docrec.media_id);
				FETCH longtext INTO long_text_tmp;
				CLOSE longtext;
				INSERT INTO fnd_documents_long_text (
					media_id,
					long_text)
				 VALUES (
					media_id_tmp,
					long_text_tmp);
			media_id_tmp := '';
		        ELSIF (docrec.datatype_id=6) THEN

                         OPEN fnd_lobs_cur(docrec.media_id);
                         FETCH fnd_lobs_cur
                           INTO fnd_lobs_rec.file_id,
                                fnd_lobs_rec.file_name,
                                fnd_lobs_rec.file_content_type,
                                fnd_lobs_rec.upload_date,
                                fnd_lobs_rec.expiration_date,
                                fnd_lobs_rec.program_name,
                                fnd_lobs_rec.program_tag,
                                fnd_lobs_rec.file_data,
                                fnd_lobs_rec.language,
                                fnd_lobs_rec.oracle_charset,
                                fnd_lobs_rec.file_format;
                         CLOSE fnd_lobs_cur;
             INSERT INTO fnd_lobs (
                                 file_id,
                                 file_name,
                                 file_content_type,
                                 upload_date,
                                 expiration_date,
                                 program_name,
                                 program_tag,
                                 file_data,
                                 language,
                                 oracle_charset,
                                 file_format)
               VALUES  (
                       media_id_tmp,
                       fnd_lobs_rec.file_name,
                       fnd_lobs_rec.file_content_type,
                       fnd_lobs_rec.upload_date,
                       fnd_lobs_rec.expiration_date,
                       fnd_lobs_rec.program_name,
                       fnd_lobs_rec.program_tag,
                       fnd_lobs_rec.file_data,
                       fnd_lobs_rec.language,
                       fnd_lobs_rec.oracle_charset,
                       fnd_lobs_rec.file_format);

                       media_id_tmp := '';
		  END IF;  -- end of duplicating text

		END IF;   --  end if usage_type = 'O' and datatype in (1,2,6)
		--  Create attachment record
    SELECT fnd_attached_documents_s.NEXTVAL
    INTO l_to_attachment_id
    FROM dual;
		INSERT INTO fnd_attached_documents
		(attached_document_id,
		document_id,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		seq_num,
		entity_name,
		pk1_value, pk2_value, pk3_value,
		pk4_value, pk5_value,
		automatically_added_flag,
		program_application_id, program_id,
		program_update_date, request_id,
		attribute_category, attribute1,
		attribute2, attribute3, attribute4,
		attribute5, attribute6, attribute7,
		attribute8, attribute9, attribute10,
		attribute11, attribute12, attribute13,
		attribute14, attribute15, column1, category_id) VALUES
		(l_to_attachment_id,
		docrec.document_id,
		sysdate,
		NVL(X_created_by,0),
		sysdate,
		NVL(X_created_by,0),
		X_last_update_login,
		docrec.seq_num,
		X_to_entity_name,
		X_to_pk1_value,
                X_to_pk2_value,
                X_to_pk3_value,
		X_to_pk4_value,
                X_to_pk5_value,
		docrec.automatically_added_flag,
		X_program_application_id, X_program_id,
		sysdate, X_request_id,
		docrec.attribute_category, docrec.attribute1,
		docrec.attribute2, docrec.attribute3,
		docrec.attribute4, docrec.attribute5,
		docrec.attribute6, docrec.attribute7,
		docrec.attribute8, docrec.attribute9,
		docrec.attribute10, docrec.attribute11,
		docrec.attribute12, docrec.attribute13,
		docrec.attribute14, docrec.attribute15,
		docrec.column1,
		NVL(X_to_category_id, NVL(docrec.att_cat, docrec.category_id)));

    X_to_attachment_id := l_to_attachment_id;

		--  Update the document to be a std document if it
		--  was an ole or image that wasn't already a std doc
		--  (images should be created as Std, but just in case)
		IF (docrec.datatype_id IN (3,4)
		    AND docrec.usage_type <> 'S') THEN
			UPDATE fnd_documents
			   SET usage_type = 'S'
			WHERE document_id = docrec.document_id;
		END IF;
	END LOOP;  --  end of working through all attachments
--  close cursors.
        IF    X_from_pk2_value IS NULL THEN -- performance change IF
          CLOSE docpk1;
        ELSIF X_from_pk3_value IS NULL THEN
          CLOSE docpk2;
        ELSIF X_from_pk4_value IS NULL THEN
          CLOSE docpk3;
        ELSE
          CLOSE doclist;
        END IF;

       EXCEPTION WHEN OTHERS THEN
       -- need to close all cursors
         l_something := SQLERRM;
       CLOSE docpk1;
       CLOSE docpk2;
       CLOSE docpk3;
       CLOSE doclist;
       CLOSE shorttext;
       CLOSE longtext;
       CLOSE fnd_lobs_cur;

END copy_attachments_fnd;



PROCEDURE copy_attachments(X_from_entity_name IN VARCHAR2,
			X_from_pk1_value IN VARCHAR2,
			X_from_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_from_pk5_value IN VARCHAR2 DEFAULT NULL,
      X_from_attachment_id IN NUMBER DEFAULT NULL,
			X_to_entity_name IN VARCHAR2,
			X_to_pk1_value IN VARCHAR2,
			X_to_pk2_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk3_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk4_value IN VARCHAR2 DEFAULT NULL,
			X_to_pk5_value IN VARCHAR2 DEFAULT NULL,
      X_to_attachment_id IN OUT NOCOPY NUMBER,
			X_created_by IN NUMBER DEFAULT NULL,
			X_last_update_login IN NUMBER DEFAULT NULL,
			X_program_application_id IN NUMBER DEFAULT NULL,
			X_program_id IN NUMBER DEFAULT NULL,
			X_request_id IN NUMBER DEFAULT NULL,
			X_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
			X_from_category_id IN NUMBER DEFAULT NULL,
			X_to_category_id IN NUMBER DEFAULT NULL) IS
  l_delete_document_flag varchar2(1);
BEGIN

  copy_attachments_fnd(X_from_entity_name,
			X_from_pk1_value,
			X_from_pk2_value,
			X_from_pk3_value,
			X_from_pk4_value,
			X_from_pk5_value,
      X_from_attachment_id,
			X_to_entity_name,
			X_to_pk1_value,
			X_to_pk2_value,
			X_to_pk3_value,
			X_to_pk4_value,
			X_to_pk5_value,
      X_to_attachment_id,
			X_created_by,
			X_last_update_login,
			X_program_application_id,
			X_program_id,
			X_request_id,
			X_automatically_added_flag,
			X_from_category_id,
			X_to_category_id);



EXCEPTION WHEN OTHERS THEN
NULL;


END  copy_attachments;


END DOM_ATTACHMENT_UTIL_PKG;

/
