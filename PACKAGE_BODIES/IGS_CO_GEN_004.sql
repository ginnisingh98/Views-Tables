--------------------------------------------------------
--  DDL for Package Body IGS_CO_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_GEN_004" AS
/* $Header: IGSCO23B.pls 120.0 2005/06/01 19:04:52 appldev noship $ */

/* +=======================================================================+
   |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
   |                         All rights reserved.                          |
   +=======================================================================+
   |  NAME                                                                 |
   |    IGSCO23B.pls                                                       |
   |                                                                       |
   |  DESCRIPTION                                                          |
   |    This package provides service functions and procedures to          |
   |    correspondence forms for sending test mails, resending requests    |
   |                                    and view attachments .             |
   |                                                                       |
   |  NOTES                                                                |
   |                                                                       |
   |  DEPENDENCIES                                                         |
   |                                                                       |
   |  USAGE                                                                |
   |                                                                       |
   |  HISTORY                                                              |
   |  who      when               what                                     |
   | kumma     20-AUG-2003        3091685, modified the get_attachments    |
   |                              to use the exists before accessing the   |
   |                              plsql table                              |
   | ssawhney  3-may-04           IBC.C patchset changes bug 3565861 + 3442719
   |                                                                       |
   +=======================================================================+ */

 PROCEDURE resend_request
     (
          X_ROWID			      IN OUT NOCOPY VARCHAR2,
	  X_STUDENT_ID			      IN     NUMBER,
          X_DOCUMENT_ID			      IN     NUMBER,
	  X_DOCUMENT_TYPE		      IN     VARCHAR2,
	  X_SYS_LTR_CODE		      IN     VARCHAR2,
	  X_ADM_APPLICATION_NUMBER	      IN     NUMBER,
          X_NOMINATED_COURSE_CD               IN     VARCHAR2,
	  X_SEQUENCE_NUMBER                   IN     NUMBER,
	  X_CAL_TYPE                          IN     VARCHAR2,
	  X_CI_SEQUENCE_NUMBER                IN     NUMBER,
	  X_REQUESTED_DATE                    IN     DATE,
	  X_DELIVERY_TYPE                     IN     VARCHAR2,
          X_OLD_REQUEST_ID		      IN     NUMBER,
          X_NEW_REQUEST_ID		      OUT    NOCOPY NUMBER,
          X_MSG_COUNT			      OUT    NOCOPY NUMBER,
          X_MSG_DATA			      OUT    NOCOPY VARCHAR2,
          X_RETURN_STATUS		      OUT    NOCOPY VARCHAR2,
          P_COMMIT			      IN     VARCHAR2 ,
	  X_VERSION_ID                        IN     NUMBER
     )
  ------------------------------------------------------------------
  --Created by  : kumma, Oracle India ()
  --Date created: 06-jun-2003
  --
  --Purpose: 2853531
  --   This procedure is used to re-send the request for a particular template document
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ssawhney    12-may-2004     version_id added in CO_INTERACTION_HISTORY
  -------------------------------------------------------------------
 IS

     l_api_version             NUMBER          ;
     l_init_msg_list           VARCHAR2(2)     ;
     l_commit                  VARCHAR2(2)     ;
     l_validation_level        NUMBER          ;
     l_msg_index_out           NUMBER;
     l_tmp_var1                VARCHAR2(2000);
     l_tmp_var                 VARCHAR2(2000);

 BEGIN
     l_api_version            	:= 1.0;
     l_init_msg_list            := FND_API.G_TRUE;
     l_commit                   := FND_API.G_FALSE;
     l_validation_level         := FND_API.G_VALID_LEVEL_FULL;

     JTF_FM_Request_GRP.Resubmit_Request
     (
     	  p_api_version           =>	l_api_version,
          p_init_msg_list         =>	l_init_msg_list,
          p_commit                =>	l_commit,
          p_validation_level      =>	l_validation_level,
          x_return_status         =>	X_RETURN_STATUS,
          x_msg_count             =>	X_MSG_COUNT,
          x_msg_data		  =>	X_MSG_DATA,
          p_request_id		  =>	x_old_request_id,
          x_request_id		  =>	x_new_request_id
     );


     IF X_RETURN_STATUS  IN ('E','U') THEN
          IF x_msg_count > 1 THEN
               FOR i IN 1..x_msg_count
               LOOP
                    l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                    l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
               END LOOP;
               x_msg_data := l_tmp_var1;
          END IF;
     ELSE

          --Request submitted successfully and we need to insert a history record
	  igs_co_interac_hist_pkg.insert_row (
	       x_rowid                             =>	  x_rowid,
	       x_student_id                        =>     x_student_id,
  	       x_request_id                        =>     x_new_request_id,
	       x_document_id                       =>     x_document_id,
	       x_document_type                     =>     x_document_type,
	       x_sys_ltr_code                      =>     x_sys_ltr_code,
	       x_adm_application_number            =>     x_adm_application_number,
	       x_nominated_course_cd               =>     x_nominated_course_cd,
	       x_sequence_number                   =>     x_sequence_number,
	       x_cal_type                          =>     x_cal_type,
	       x_ci_sequence_number                =>     x_ci_sequence_number,
	       x_requested_date                    =>     x_requested_date,
	       x_delivery_type                     =>     x_delivery_type,
	       x_mode                              =>     'R' ,
	       x_version_id                        =>     x_version_id
	  );

          IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
          END IF;
     END IF;
 END resend_request;



 PROCEDURE send_test_mail
 (
     X_MAIL_ID                        IN     VARCHAR2,
     X_SUBJECT                        IN     VARCHAR2,
     X_CRM_USER_ID                    IN     NUMBER,
     X_TEMPLATE_ID                    IN     NUMBER,
     X_VERSION_ID                     IN     NUMBER,
     X_MSG_COUNT		      OUT    NOCOPY NUMBER,
     X_MSG_DATA			      OUT    NOCOPY VARCHAR2,
     X_RETURN_STATUS		      OUT    NOCOPY VARCHAR2,
     X_REQUEST_ID                     OUT    NOCOPY NUMBER,
     P_COMMIT			      IN     VARCHAR2
 )
  ------------------------------------------------------------------
  --Created by  : kumma, Oracle India ()
  --Date created: 06-jun-2003
  --
  --Purpose: 2853531
  --   This procedure is used to send the test mails for a particular template document
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ssawhney    3-may-04        IBC.C patchset changes bug 3565861 + 3442719
  -------------------------------------------------------------------
 IS

     l_init_msg_list           VARCHAR2(2);
     l_api_version             NUMBER ;
     l_order_header_rec        JTF_Fulfillment_PUB.ORDER_HEADER_REC_TYPE;
     y_order_header_rec        ASO_ORDER_INT.ORDER_HEADER_REC_TYPE;
     l_order_line_tbl          JTF_Fulfillment_PUB.ORDER_LINE_TBL_TYPE;
     l_fulfill_electronic_rec  JTF_FM_OCM_REQUEST_GRP.FULFILL_ELECTRONIC_REC_TYPE;
     l_request_type            VARCHAR2(32);
     l_msg_index_out           NUMBER;
     party_id                  JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE;
     email 		       JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
     l_tmp_var1                VARCHAR2(2000);
     l_tmp_var                 VARCHAR2(2000);

     i NUMBER;
 BEGIN
     l_fulfill_electronic_rec.request_type    :=    'T';
     l_fulfill_electronic_rec.template_id     :=    X_TEMPLATE_ID;
     l_fulfill_electronic_rec.version_id      :=    X_VERSION_ID;
     l_fulfill_electronic_rec.requestor_id    :=    X_CRM_USER_ID;
     l_fulfill_electronic_rec.subject         :=    X_SUBJECT;

     --l_fulfill_electronic_rec.party_id(1)     :=     101;   -- Not Required
     l_fulfill_electronic_rec.email(1)        :=     X_MAIL_ID;
     l_init_msg_list       := FND_API.G_TRUE;
     l_api_version         := 1.0;

     JTF_FM_OCM_REQUEST_GRP.create_fulfillment(
          p_init_msg_list          =>     l_init_msg_list,
          p_api_version            =>     l_api_version,
          p_commit                 =>     p_commit,
          p_order_header_rec       =>     l_order_header_rec,
          p_order_line_tbl         =>     l_order_line_tbl,
          p_fulfill_electronic_rec =>     l_fulfill_electronic_rec,
          p_request_type           =>     l_request_type,
          x_return_status          =>     X_RETURN_STATUS,
          x_msg_count              =>     X_MSG_COUNT,
          x_msg_data               =>     X_MSG_DATA,
          x_order_header_rec       =>     y_order_header_rec,
          x_request_history_id     =>     X_REQUEST_ID
     );


     IF X_RETURN_STATUS  IN ('E','U') THEN
          IF x_msg_count > 1 THEN
               /* FOR i IN 1..x_msg_count
               LOOP
                    l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                    l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
               END LOOP;
               x_msg_data := l_tmp_var1;  */
	       FOR i IN 1..x_msg_count
               LOOP
                    l_tmp_var := fnd_msg_pub.get(i, fnd_api.g_false);
                    l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
               END LOOP;
               x_msg_data := l_tmp_var1;
          END IF;

     ELSIF X_RETURN_STATUS ='S' THEN  -- if successful, call commit.
     -- this should resolve issue in bug 3442719
           COMMIT WORK;
     END IF;


 END send_test_mail;




  PROCEDURE get_attachments
  (
     p_version_id		IN NUMBER,
     x_item_id                  OUT NOCOPY NUMBER,
     x_item_name                OUT NOCOPY VARCHAR2,
     x_version                  OUT NOCOPY NUMBER,
     x_item_description         OUT NOCOPY VARCHAR2,
     x_type_code                OUT NOCOPY VARCHAR2,
     x_type_name                OUT NOCOPY VARCHAR2,
     x_attribute_type_codes	OUT NOCOPY T_VARCHAR_100,
     x_attribute_type_names	OUT NOCOPY T_VARCHAR_300,
     x_attributes		OUT NOCOPY T_VARCHAR_4000,
     x_component_citems		OUT NOCOPY T_NUMBER,
     x_component_attrib_types	OUT NOCOPY T_VARCHAR_100,
     x_component_citem_names	OUT NOCOPY T_VARCHAR_300,
     x_component_owner_ids	OUT NOCOPY T_NUMBER,
     x_component_owner_types	OUT NOCOPY T_VARCHAR_100,
     x_component_sort_orders	OUT NOCOPY T_NUMBER,
     x_return_status		OUT NOCOPY VARCHAR2,
     x_msg_count		OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2
  )
  ------------------------------------------------------------------
  --Created by  : kumma, Oracle India ()
  --Date created: 06-jun-2003
  --
  --Purpose: 2853531
  --   This procedure is used to fetch the attachments/deliverables attached to a particular template
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  IS

     dir_node_id            ibc_content_items.directory_node_id%TYPE;
     dir_node_name          ibc_directory_nodes_tl.directory_node_name%TYPE;
     dir_node_code          ibc_directory_nodes_b.directory_node_code%TYPE;
     item_status            ibc_content_items.content_item_status%TYPE;
     version_status         ibc_citem_versions_b.citem_version_status%TYPE;
     start_date             ibc_citem_versions_b.start_date%TYPE;
     end_date               ibc_citem_versions_b.end_date%TYPE;
     owner_resource_id      NUMBER;
     owner_resource_type    VARCHAR2(100);
     reference_code         VARCHAR2(100);
     trans_required         ibc_content_items.translation_required_flag%TYPE;
     parent_item_id         ibc_content_items.parent_item_id%TYPE;
     locked_by              ibc_content_items.locked_by_user_id%TYPE;
     wd_restricted          ibc_content_items.wd_restricted_flag%TYPE;
     attach_file_id         ibc_citem_versions_tl.attachment_file_id%TYPE;
     attach_file_name       ibc_citem_versions_tl.attachment_file_name%TYPE;
     object_version_number  ibc_content_items.object_version_number%TYPE;
     created_by             NUMBER;
     creation_date          DATE;
     last_updated_by        NUMBER;
     last_update_date       DATE;


     l_attribute_type_codes  	JTF_VARCHAR2_TABLE_100	;
     l_attribute_type_names  	JTF_VARCHAR2_TABLE_300	;
     l_attributes             	JTF_VARCHAR2_TABLE_4000	;
     l_component_citems      	JTF_NUMBER_TABLE	;
     l_component_attrib_types 	JTF_VARCHAR2_TABLE_100	;
     l_component_citem_names	JTF_VARCHAR2_TABLE_300	;
     l_component_owner_ids    	JTF_NUMBER_TABLE	;
     l_component_owner_types	JTF_VARCHAR2_TABLE_100	;
     l_component_sort_orders  	JTF_NUMBER_TABLE	;

     l_temp_component_attrib_types  IGS_CO_GEN_004.T_VARCHAR_100;
     l_temp_component_citem_names   IGS_CO_GEN_004.T_VARCHAR_300;

     l_tmp_var1                VARCHAR2(2000);
     l_tmp_var                 VARCHAR2(2000);

  BEGIN

     l_attribute_type_codes  	:=	JTF_VARCHAR2_TABLE_100();
     l_attribute_type_names  	:=	JTF_VARCHAR2_TABLE_300();
     l_attributes             	:=	JTF_VARCHAR2_TABLE_4000();
     l_component_citems      	:=	JTF_NUMBER_TABLE();
     l_component_attrib_types 	:=	JTF_VARCHAR2_TABLE_100();
     l_component_citem_names	:=	JTF_VARCHAR2_TABLE_300();
     l_component_owner_ids    	:=	JTF_NUMBER_TABLE();
     l_component_owner_types	:=	JTF_VARCHAR2_TABLE_100();
     l_component_sort_orders  	:=	JTF_NUMBER_TABLE();

     IBC_CITEM_ADMIN_GRP.get_item (
          p_citem_ver_id			=>	p_version_id,  --Version is same as the content_id
	  p_init_msg_list			=>	FND_API.g_true,
	  p_api_version_number			=>	IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT,
          x_content_item_id			=>	x_item_id,
          x_citem_name				=>	x_item_name,
          x_citem_version			=>	x_version,
          x_dir_node_id            		=>	dir_node_id,
          x_dir_node_name          		=>	dir_node_name,
          x_dir_node_code          		=>	dir_node_code,
          x_item_status            		=>	item_status,
          x_version_status         		=>	version_status,
          x_citem_description    		=>	x_item_description,
          x_ctype_code            		=>	x_type_code,
          x_ctype_name            		=>	x_type_name,
          x_start_date            		=>	start_date,
          x_end_date              		=>	end_date,
          x_owner_resource_id      		=>	owner_resource_id,
          x_owner_resource_type   		=>	owner_resource_type,
          x_reference_code         		=>	reference_code,
          x_trans_required        		=>	trans_required,
          x_parent_item_id        		=>	parent_item_id,
          x_locked_by             		=>	locked_by,
          x_wd_restricted          		=>	wd_restricted,
          x_attach_file_id        		=>	attach_file_id,
          x_attach_file_name       		=>	attach_file_name,
          x_object_version_number  		=>	object_version_number,
          x_created_by           		=>	created_by,
          x_creation_date          		=>	creation_date,
          x_last_updated_by        		=>	last_updated_by,
          x_last_update_date       		=>	last_update_date,
          x_attribute_type_codes  		=>	l_attribute_type_codes,
          x_attribute_type_names  		=>	l_attribute_type_names,
          x_attributes             		=>	l_attributes,
          x_component_citems      		=>	l_component_citems,
          x_component_attrib_types 		=>	l_component_attrib_types,
          x_component_citem_names		=>	l_component_citem_names,
          x_component_owner_ids    		=>	l_component_owner_ids,
          x_component_owner_types		=>	l_component_owner_types,
          x_component_sort_orders  		=>	l_component_sort_orders,
          x_return_status         		=>	x_return_status,
          x_msg_count              		=>	x_msg_count,
          x_msg_data              		=>	x_msg_data
     );



     IF X_RETURN_STATUS  IN ('E','U') THEN
          IF x_msg_count > 0 THEN
               /* FOR i IN 1..x_msg_count
               LOOP
                    l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                    l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
               END LOOP;
               x_msg_data := l_tmp_var1;  */
	       FOR i IN 1..x_msg_count
               LOOP
                    l_tmp_var := fnd_msg_pub.get(i, fnd_api.g_false);
                    l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
               END LOOP;
               x_msg_data := l_tmp_var1;
          END IF;
     ELSE

          IF l_component_attrib_types.exists(1) THEN
               FOR count1 IN 1..l_component_attrib_types.count LOOP
	            x_component_attrib_types(count1) := l_component_attrib_types(count1);
               END LOOP;
          END IF;

          IF l_component_citem_names.exists(1) THEN
               FOR count2 IN 1..l_component_citem_names.count LOOP
      	            x_component_citem_names(count2) := l_component_citem_names(count2);
               END LOOP;
          END IF;
     END IF;


  END get_attachments;

PROCEDURE get_list_query (
	p_file_id	IN	NUMBER,
	p_query_text    OUT NOCOPY VARCHAR2
)
  ------------------------------------------------------------------
  --Created by  : kumma, Oracle India ()
  --Date created: 06-jun-2003
  --
  --Purpose: 2853531
  --   This procedure is used to fetch the query for a particular dynamic group whose id is passed as a parameter
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
AS
	l_xmlBlob_loc	BLOB;
	l_rawBuffer	RAW(32767);
	l_amount	BINARY_INTEGER;
	l_chunksize	INTEGER;
	l_totalLen	INTEGER;
	l_offset	INTEGER ;
	l_query         VARCHAR2(32000);
BEGIN
     l_amount	:= 32767;
     l_offset	:= 1;

     IF (p_file_id IS NOT NULL) THEN
	  SELECT file_data INTO l_xmlBlob_loc
	  FROM fnd_lobs
	  WHERE file_id = p_file_id;

          l_totalLen := DBMS_LOB.GETLENGTH(l_xmlBlob_loc);
          l_chunksize := DBMS_LOB.GETCHUNKSIZE(l_xmlBlob_loc);

	  IF (l_chunksize < 32767) THEN
      	       l_amount := (32767 / l_chunksize) * l_chunksize;
   	  END IF;

	  l_query := '';
          WHILE l_totalLen >= l_amount LOOP
               DBMS_LOB.READ(l_xmlBlob_loc, l_amount, l_offset, l_rawBuffer);
	       --DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, utl_raw.LENGTH(l_rawBuffer), utl_raw.cast_to_varchar2(l_rawBuffer));
	       l_query := l_query ||  utl_raw.cast_to_varchar2(l_rawBuffer);
	       l_totalLen := l_totalLen - l_amount;
	       l_offset := l_offset + l_amount;
	  END LOOP;

	  IF l_totalLen > 0 THEN
	       DBMS_LOB.READ(l_xmlBlob_loc, l_totalLen, l_offset, l_rawBuffer);
               l_query := l_query || utl_raw.cast_to_varchar2(l_rawBuffer);
   	       --DBMS_LOB.WRITEAPPEND(p_xml_clob_loc, utl_raw.LENGTH(l_rawBuffer), utl_raw.cast_to_varchar2(l_rawBuffer));
	  END IF;
	  p_query_text := l_query;
     END IF;

	-- If Content Item does not have user-defined primitive
	-- attributes, do nothing.

END get_list_query;


PROCEDURE create_associations (
        p_doc_id              IN NUMBER,
        p_assoc_type_codes    IN VARCHAR2,
        p_letter_code         IN VARCHAR2,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2
	)
  ------------------------------------------------------------------
  --Created by  : ssawhney, Oracle India ()
  --Date created: 06-may-2004
  --
  --Purpose: IBC.C patchset changes bug 3565861
  --   This procedure is used create associations in OCM for CRM doc_id and OSS letter code
  --   This will help protect the doc_id of CRM to be deleted from anywhere.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
AS

    --l_content_item_id  JTF_VARCHAR2_TABLE;
    l_assoc_objects2  JTF_VARCHAR2_TABLE_300 ;
    l_assoc_objects3  JTF_VARCHAR2_TABLE_300 ;
    l_assoc_objects4  JTF_VARCHAR2_TABLE_300 ;
    l_assoc_objects5  JTF_VARCHAR2_TABLE_300 ;
    l_assoc_type_codes    JTF_VARCHAR2_TABLE_100;
    l_letter_code         JTF_VARCHAR2_TABLE_300;
    l_tmp_var1        VARCHAR2(4000);
    l_tmp_var         VARCHAR2(4000);
    i number;
    l_length number;

BEGIN
    i:=0;
    -- initalize all varrays, else we get subscription out of bound or uninitialized collection errors.
    --l_content_item_id := JTF_NUMBER_TABLE()  ;
    l_assoc_objects2  := JTF_VARCHAR2_TABLE_300()  ;
    l_assoc_objects3  := JTF_VARCHAR2_TABLE_300()  ;
    l_assoc_objects4  := JTF_VARCHAR2_TABLE_300()  ;
    l_assoc_objects5  := JTF_VARCHAR2_TABLE_300()  ;
    l_letter_code     := JTF_VARCHAR2_TABLE_300()  ;
    l_assoc_type_codes :=  JTF_VARCHAR2_TABLE_100() ;

    l_assoc_type_codes.EXTEND;
    l_letter_code.EXTEND;

    l_letter_code(1)  := p_letter_code;


    IF p_assoc_type_codes ='SYSTEM' THEN
       l_assoc_type_codes(1) := 'IGS_SYSTEM' ;
    ELSIF p_assoc_type_codes ='AD-HOC' THEN
       l_assoc_type_codes(1) := 'IGS_ADHOC' ;
    END IF;


    IBC_CITEM_ADMIN_GRP.insert_associations(
         p_content_item_id    => p_doc_id
        ,p_assoc_type_codes   => l_assoc_type_codes
        ,p_assoc_objects1     => l_letter_code
        ,p_commit             => FND_API.G_TRUE
        ,p_init_msg_list      => FND_API.G_TRUE
        ,p_api_version_number => IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
    );


     IF X_RETURN_STATUS  IN ('E','U') THEN
          IF x_msg_count > 1 THEN
               FOR i IN 1..x_msg_count
               LOOP
                    l_tmp_var := fnd_msg_pub.get(i, fnd_api.g_false);
                    l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
               END LOOP;
               x_msg_data := l_tmp_var1;
          END IF;

     END IF;


END create_associations;

END IGS_CO_GEN_004;

/
