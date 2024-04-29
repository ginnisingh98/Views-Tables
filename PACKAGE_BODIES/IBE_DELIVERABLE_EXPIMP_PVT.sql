--------------------------------------------------------
--  DDL for Package Body IBE_DELIVERABLE_EXPIMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DELIVERABLE_EXPIMP_PVT" AS
 /* $Header: IBEVDEIB.pls 120.1 2007/10/17 10:33:42 scnagara ship $ */
/*======================================================================+
|  Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
|                All rights reserved.                                   |
+=======================================================================+
| FILENAME                                                              |
|     IBEVDEIB.pls                                                      |
|                                                                       |
| DESCRIPTION                                                           |
|     procedures for export import of deliverables                      |
|                                                                       |
| HISTORY                                                               |
|     08/26/2003  ABHANDAR  Created                                     |
|     03/23/2005  RGUPTA    Added p_enable_debug param                  |
|     17/10/2007  SCNAGARA  Fix for Bug#5882497				|
+=======================================================================*/
----added 07/29/03 by abhandar for template export and import----
--******************************************************************************
-- Procedure to import templates
-- Seeded templates and it's mappings are not modifiable during import.
-- The non seeded ones can be modified during import
-- If the site code is null, the mappings are not imported( error logged in the error log)
--
-- User may modify the following fields in the input xml file  -->
--
--1) ProgrammaticAccessName(jtf_amv_items_b.access_name) --> Create a new  template  with this acces name
--2) Name(jtf_amv_items_tl.item_name)--> Update the existing template Name value to reflect the new value
--3) Description(jtf_amv_items_tl.description)-->Update the existing template  Description value to reflect the new value
--4) Keywords(jtf_amv_items_keywords.keywords)-->pdate the existing template Keywords value to reflect the new value
--5) Seed flag-->  No effect field is only for informational purpose
--6) Applicable_to(jtf_amv_items_b.applicable_to)-->Update the existing template 'applicable to' value to reflect the new value
--7) Seed map-->  No effect, field is only for informational purpose
--8) Site code--> Create a new mapping for the template with this site id
--9) Site name--> No effect, field is only for informational purpose
--10)Language-->  Create a new mapping for the template with this lang code
--11)File name--> Update the filename in the jtf_amv_attachments table
--12)Def site-->  Create a new mapping for the template with this flag
--13)Def lang-->  Create a new mapping for the template with this flag
--*******************************************************************************

PROCEDURE save_template_mapping(
  p_api_version             IN NUMBER,
  p_init_msg_list           IN VARCHAR2 := FND_API.g_false,
  p_commit                  IN VARCHAR2 := FND_API.g_false,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY VARCHAR2,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_error_num               IN OUT NOCOPY NUMBER,
  p_error_limit             IN NUMBER,
  p_access_name             IN VARCHAR2,
  p_item_name               IN VARCHAR2,
  p_description             IN VARCHAR2,
  p_applicable_to           IN VARCHAR2,
  p_keywords                IN VARCHAR2,
  p_minisite_ids            IN JTF_NUMBER_TABLE,
  p_language_codes          IN JTF_VARCHAR2_TABLE_100,
  p_default_sites           IN JTF_VARCHAR2_TABLE_100,
  p_default_languages       IN JTF_VARCHAR2_TABLE_100,
  p_file_names              IN JTF_VARCHAR2_TABLE_100,
  p_enable_debug            IN VARCHAR2)
 IS
  L_API_NAME    CONSTANT VARCHAR2(30) := 'save_template_mapping';
  L_API_VERSION CONSTANT NUMBER := 1.0;

  l_appl_id NUMBER := 671;
  l_attachment_used_by  VARCHAR2(30):='ITEM';

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_true VARCHAR2(1);

  l_mode                    VARCHAR2(20) := 'EXECUTION';
  l_status                  VARCHAR2(4);
  l_debugMsgBuf             VARCHAR(2000);
  l_next_val   NUMBER;

  CURSOR c_lgl_phys_map_seq IS
          SELECT IBE_DSP_LGL_PHYS_MAP_S1.NEXTVAL
          FROM DUAL;

  CURSOR c_get_template_csr(c_access_name VARCHAR2) IS
    SELECT item_id,object_version_number
      FROM jtf_amv_items_b
     WHERE access_name = c_access_name
       AND application_id = 671
       AND deliverable_type_code = 'TEMPLATE';

   -- cursor to get the map id and attachment id.
   CURSOR c_get_map_csr(c_item_id VARCHAR2,
                       c_site_id NUMBER,
                       c_lang_code VARCHAR2,
                       c_default_site VARCHAR2,
                       c_default_lang VARCHAR2) IS
    SELECT lgl_phys_map_id, attachment_id
      FROM ibe_dsp_lgl_phys_map
      WHERE item_id = c_item_id
       AND msite_id = c_site_id
       AND language_code = c_lang_code
       AND default_site = c_default_site
       AND default_language = c_default_lang;

   -- cursor to load the attachment info
   CURSOR c_get_attachment_csr(c_attachment_id NUMBER) IS
    SELECT
    attachment_id,		-- Bug#5882497, scnagara
    object_version_number,
	attachment_used_by,
  	enabled_flag,
  	can_fulfill_electronic_flag,
  	file_id,
  	file_extension,
  	keywords,
  	send_for_preview_flag,
  	attachment_type,
  	language_code,
  	application_id,
  	description
   FROM JTF_AMV_ATTACHMENTS
   WHERE attachment_id=c_attachment_id;

  -- Bug5882497
  CURSOR c_get_attachment_id_csr(c_item_id ibe_dsp_lgl_phys_map.item_id%type,
				 c_file_name jtf_amv_attachments.file_name%type) IS
    SELECT
	ibemap.attachment_id
	FROM
	jtf_amv_attachments jtfach,ibe_dsp_lgl_phys_map ibemap
	WHERE
        ibemap.attachment_id = jtfach.attachment_id
	and ibemap.item_id   = c_item_id
	and jtfach.file_name = c_file_name
	group by ibemap.attachment_id;

  l_object_ver_num  NUMBER;
  l_item_id NUMBER;
  l_lgl_phys_map_id NUMBER;
  l_attachment_id NUMBER;
  l_deliverable_rec IBE_DELIVERABLE_GRP.DELIVERABLE_REC_TYPE;
  l_attachment_rec IBE_ATTACHMENT_GRP.ATTACHMENT_REC_TYPE;

BEGIN
 l_true:=FND_API.g_true;

 -- begin log message initialization

  FND_GLOBAL.APPS_INITIALIZE(5,20420,1);
  FND_PROFILE.Put('AFLOG_ENABLED', 'Y');
  FND_PROFILE.Put('AFLOG_LEVEL',FND_LOG.LEVEL_EVENT);
  FND_LOG_REPOSITORY.Init;

  IF (p_enable_debug = 'Y') THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '*****Template import Starts-'||to_char(sysdate,'MM/DD/RRRR HH24:MI:SS'));
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT save_template_mapping_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_Msg_Pub.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- API body
  -- Check if the template exists or not
  IF (p_enable_debug = 'Y') THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Opening cursor c_get_template_csr');
  END IF;
  OPEN c_get_template_csr(p_access_name);
  FETCH c_get_template_csr INTO l_item_id ,l_object_ver_num;
  IF (c_get_template_csr%NOTFOUND) THEN
       IF (p_enable_debug = 'Y') THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_item_id is null');
       END IF;
      l_item_id := NULL;
  END IF;
  CLOSE c_get_template_csr;
  l_deliverable_rec.item_type           :='TEMPLATE';
  l_deliverable_rec.access_name         := p_access_name;
  l_deliverable_rec.display_name        := p_item_name;
  l_deliverable_rec.description         := p_description;
  l_deliverable_rec.item_applicable_to  := p_applicable_to;
  l_deliverable_rec.keywords            := p_keywords;
  l_deliverable_rec.deliverable_id      := l_item_id;
  l_deliverable_rec.object_version_number:=l_object_ver_num;

  IF (p_enable_debug = 'Y') THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Step 1 : item_id='||l_item_id||
                      ':access_name='||p_access_name||
                      ':display_name='||p_item_name||
                      ':description='||p_description||
                      ':applicable_to='||p_applicable_to||
                      'p_keywords='||p_keywords||
                      ':object ver num='||l_object_ver_num);
  END IF;

  -- Check if the existing template is seed or not. Seed templates are not modifiable
  -- For non-seed template, create a new template / update the existing template.

  IF (l_item_id IS NULL) OR (l_item_id >=10000) THEN

    IF (p_enable_debug = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Before calling IBE_Deliverable_Grp.save_deliverable');
    END IF;

    IBE_Deliverable_GRP.save_deliverable(
      p_api_version => 1.0,
      p_init_msg_list => FND_API.g_false,
      p_commit => FND_API.g_false,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_deliverable_rec => l_deliverable_rec);

    IF (p_enable_debug = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Step 2 :After item save :return status='||l_return_status);
    END IF;
    l_item_id := l_deliverable_rec.deliverable_id;
    IF (p_enable_debug = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Step 2a :l_item_id='||l_item_id);
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

 IF (p_enable_debug = 'Y') THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'step2b : number of array count ='||p_minisite_ids.COUNT);
 END IF;
  -- Process the template mappings
  FOR l_i IN 1..p_minisite_ids.COUNT LOOP
    -- Check if the mapping exists or not
    IF (p_enable_debug = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Step 3 : itemid='||l_item_id||
                        ':access_name='||p_access_name||
                        'msite_id='||p_minisite_ids(l_i)||
                        'langcode='||p_language_codes(l_i)||
                        'p_default_sites='||p_default_sites(l_i)||
                        'p_default_lang='||p_default_languages(l_i));
    END IF;

    OPEN c_get_map_csr(l_item_id, p_minisite_ids(l_i),
                       TRIM(p_language_codes(l_i)),
                       TRIM(p_default_sites(l_i)),
                       TRIM(p_default_languages(l_i)));

    FETCH c_get_map_csr INTO l_lgl_phys_map_id, l_attachment_id;

    IF (p_enable_debug = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Step4 : lgl_phys_map_id='||l_lgl_phys_map_id||
                        ':l_attachment_id='||l_attachment_id);
    END IF;


    IF (c_get_map_csr%NOTFOUND) THEN
      l_lgl_phys_map_id := NULL;
      l_attachment_id := NULL;
    END IF;

    CLOSE c_get_map_csr;

    -- New mapping: Create new attachment and mapping
    -- Non seed existing mapping: Update attachment file name
    IF (l_lgl_phys_map_id IS NULL) OR (l_lgl_phys_map_id >= 10000) THEN

      l_attachment_rec.attachment_id := l_attachment_id;
      l_attachment_rec.file_name := p_file_names(l_i);
      l_attachment_rec.deliverable_id	:=l_item_id;
      l_attachment_rec.attachment_used_by:=l_attachment_used_by;
      l_attachment_rec.application_id:=l_appl_id;

      /* Bug#5882497, scnagara
       a) The attachment_id present for another site which corresponds to the file
          is fetched from the IBE_DSP_LGL_PHYS_MAP and JTF_AMV_ATTACHMENTS tables.
       b) The attachment_id is also passed to the IBE_Attachment_GRP.save_attachment
          through the variable of type IBE_ATTACHMENT_GRP.ATTACHMENT_REC_TYPE.
      */

      IF (p_enable_debug = 'Y') THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG,
			'Item id is '||l_item_id);
	FND_FILE.PUT_LINE(FND_FILE.LOG,
			'File name is '|| p_file_names(l_i) );
      END IF;

      OPEN c_get_attachment_id_csr(l_attachment_rec.deliverable_id,l_attachment_rec.file_name);
      FETCH c_get_attachment_id_csr INTO l_attachment_id;
      CLOSE c_get_attachment_id_csr;

      IF (p_enable_debug = 'Y') THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG,'The Attachment id is '|| l_attachment_id);
      END IF;

    -- retrieve the existing attachment details if attachment id not null
     IF (l_attachment_id IS NOT NULL AND l_attachment_id >0) then

        OPEN c_get_attachment_csr(l_attachment_id);
	-- Bug#5882497, scnagara
	-- The attachment_id is fetched into l_attachment_rec.attachment_id
        FETCH c_get_attachment_csr INTO
            l_attachment_rec.attachment_id,
            l_attachment_rec.object_version_number,
         	l_attachment_rec.attachment_used_by,
  	        l_attachment_rec.enabled_flag,
  	        l_attachment_rec.can_fulfill_electronic_flag,
  	        l_attachment_rec.file_id,
  	        l_attachment_rec.file_extension,
  	        l_attachment_rec.keywords,
  	        l_attachment_rec.send_for_preview_flag,
  	        l_attachment_rec.attachment_type,
  	        l_attachment_rec.language_code,
  	        l_attachment_rec.application_id,
  	        l_attachment_rec.description;


            IF (p_enable_debug = 'Y') THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,
                                'Step4a :object version number ='||l_attachment_rec.object_version_number);
            END IF;
          CLOSE c_get_attachment_csr;
      END IF;

      IF (p_enable_debug = 'Y') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,
                          'Step 5 :Attachment id='||l_attachment_id||
                          ':file_names='||l_attachment_rec.file_name);
      END IF;


      IBE_Attachment_GRP.save_attachment(
        p_api_version => 1.0,
        p_init_msg_list => FND_API.g_false,
        p_commit => FND_API.g_false,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_attachment_rec => l_attachment_rec);


      IF (p_enable_debug = 'Y') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Step 6 :after save atachment return status='||l_return_status);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_attachment_id := l_attachment_rec.attachment_id;
      IF (p_enable_debug = 'Y') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Step 6a :The attachment id now is='||l_attachment_id);
      END IF;

      IF (l_lgl_phys_map_id IS NULL) THEN

        IF (p_enable_debug = 'Y') THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Step 7: inserting into ibe_dsp_lgl_phys_map');
        END IF;
       -- OPEN c_lgl_phys_map_seq;
       -- FETCH c_lgl_phys_map_seq into l_next_val;
       -- close c_lgl_phys_map_seq;

        IF (p_enable_debug = 'Y') THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Step 7a :value of next sequence='||l_next_val);
        END IF;

        INSERT INTO IBE_DSP_LGL_PHYS_MAP(lgl_phys_map_id, item_id,
          msite_id, language_code, default_site, default_language,
          attachment_id, content_item_key,object_version_number,
          created_by,creation_date,last_updated_by,last_update_date)
        VALUES (IBE_DSP_LGL_PHYS_MAP_S1.NEXTVAL, l_item_id,
          p_minisite_ids(l_i), p_language_codes(l_i), p_default_sites(l_i),
          p_default_languages(l_i), l_attachment_id, NULL,
          1,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,sysdate);

        IF (p_enable_debug = 'Y') THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Step 8 :after insertion into ibe_sp_lgl_phys_map');
        END IF;


      END IF;
    END IF;

  END LOOP;
  IF (p_enable_debug = 'Y') THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Step 9: out of the mappings loop');
  END IF;
  IF (p_commit = l_true) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --x_error_num := x_error_num + 1;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Expected error in IBE_DELIVERABLE_GRP.save_template_mappping');
    END IF;
    ROLLBACK TO save_template_mapping_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --x_error_num := x_error_num + 1;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Unexpected error in IBE_DELIVERABLE_GRP.save_template_mappping');
    END IF;
    ROLLBACK TO save_template_mapping_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO save_template_mapping_pvt;
   -- x_error_num := x_error_num + 1;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Unknown error in IBE_DELIVERABLE_GRP.save_template_mappping');
    END IF;
    IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                               L_API_NAME);
    END IF;
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);
END save_template_mapping;

------------------end added by abhandar --------------------------



END IBE_DELIVERABLE_EXPIMP_PVT;

/
