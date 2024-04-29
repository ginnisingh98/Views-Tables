--------------------------------------------------------
--  DDL for Package Body JTF_PHY_MEDIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PHY_MEDIA_PVT" AS
/* $Header: JTFVDPMB.pls 120.2 2005/10/25 05:06:09 psanyal ship $ */
G_PKG_NAME  CONSTANT VARCHAR2(21):= 'JTF_PHY_MEDIA_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'JTFVDPMB.pls';
-- ****************************************************************************
-- get media given pid, catrgory id, dc id, site id
-- ****************************************************************************
PROCEDURE get_media (
  p_api_version         IN   NUMBER,
  p_init_msg_list 	IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count    OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data  	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_pid 		IN jtf_dsp_obj_lgl_ctnt.object_id%TYPE,
  p_catgid      	IN jtf_dsp_obj_lgl_ctnt.object_id%TYPE,
  p_dcname 		IN jtf_dsp_context_b.access_name%TYPE,
  p_siteid 		IN jtf_dsp_lgl_phys_map.msite_id%TYPE,
  p_langcode            IN jtf_dsp_lgl_phys_map.language_code%TYPE,
  x_filename     OUT NOCOPY /* file.sql.39 change */ jtf_amv_attachments.file_name%TYPE,
  x_description  OUT NOCOPY /* file.sql.39 change */ jtf_amv_items_vl.description%TYPE,

  -- added by Guigen Zhang 04-04-2001 16:46
  x_fileid              OUT NOCOPY /* file.sql.39 change */ jtf_amv_attachments.file_id%TYPE) IS


  l_filename jtf_amv_attachments.file_name%TYPE;
  l_description jtf_amv_items_vl.description%TYPE := 'description';

  -- modified by Guigen Zhang 04-04-2001 16:46
  l_fileid jtf_amv_attachments.file_id%TYPE;

  l_logid jtf_dsp_obj_lgl_ctnt.item_id%TYPE;
  l_api_name CONSTANT varchar2(30) := 'get_media';
  l_logmed_found boolean := false;
  l_phymed_found boolean := false;
BEGIN
  ---dbms_output.put_line('making api version call');
  IF NOT FND_API.compatible_api_call(
		g_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	) THEN
		RAISE FND_API.g_exc_unexpected_error;
	END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  ---dbms_output.put_line('  -- Initialize message list if p_init_msg_list is set to TRUE.');
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to error, i.e, its not duplicate
  x_return_status := FND_API.g_ret_sts_success;

  BEGIN
  -- First determine the logical media
  ---dbms_output.put_line(' try at pid and dc level');
  -- try at pid and dc level

    select a.item_id
      into l_logid
    from
      jtf_dsp_obj_lgl_ctnt a,
      jtf_dsp_context_b b
    where
      a.object_id = p_pid and
      a.context_id = b.context_id and
      b.access_name = p_dcname and
      a.object_type = 'I' ;
    l_logmed_found := true;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
       -- TODO put fnd_messages
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  if NOT l_logmed_found THEN
    BEGIN
      -- try at catg and dc level
      ---dbms_output.put_line(' try at catg and dc level');
      select a.item_id
        into l_logid
      from
        jtf_dsp_obj_lgl_ctnt a,
        jtf_dsp_context_b b
      where
        a.object_id = p_catgid and
        a.context_id = b.context_id and
        b.access_name = p_dcname and
        a.object_type = 'C' ;
      l_logmed_found := true;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
       WHEN OTHERS THEN
         -- TODO put fnd_messages
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    if NOT l_logmed_found THEN
      BEGIN
        -- try at the dc level
        ---dbms_output.put_line(' try at the dc level');
        select item_id
          into l_logid
        from
     	  jtf_dsp_context_b
        where
          access_name = p_dcname;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_filename := NULL;
          x_description := NULL;

          -- modified by Guigen Zhang 04-04-2001 16:46
          x_fileid := NULL;

          RETURN;
        WHEN OTHERS THEN
          -- TODO put fnd_messages
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
    END IF;
  END IF;


  BEGIN
    -- logical media has been found, get the physical media
    -- first try at the site and language
    ---dbms_output.put_line(' logical media logical id is ' || l_logid);
    ---dbms_output.put_line(' logical media has been found, try physical at the site and language');

    -- modified by Guigen Zhang 04-04-2001 16:46
    select a.file_name, b.description, a.file_id
      into l_filename, l_description, l_fileid

    from
      jtf_amv_attachments a,
      jtf_amv_items_vl b,
      jtf_dsp_lgl_phys_map c
    where
      c.item_id = l_logid and
      c.msite_id = p_siteid and
      c.language_code = p_langcode and
      c.item_id = b.item_id and
      c.attachment_id = a.attachment_id and
      a.application_id = 671 and
      b.application_id = 671;
    l_phymed_found := true;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      -- TODO put fnd_messages
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  if NOT l_phymed_found THEN
    BEGIN
      -- try at the ALL site and this language
      ---dbms_output.put_line(' try at the ALL site and this language');

      -- modified by Guigen Zhang 04-04-2001 16:46
      select a.file_name, b.description, a.file_id
      into l_filename, l_description, l_fileid

      from
        jtf_amv_attachments a,
        jtf_amv_items_vl b,
        jtf_dsp_lgl_phys_map c
      where
        c.item_id = l_logid and
        c.default_site = 'Y' and
        c.language_code = p_langcode and
        c.default_language = 'N' and
        c.attachment_id = a.attachment_id and
        c.item_id = b.item_id and
        a.application_id = 671 and
        b.application_id = 671;
      l_phymed_found := TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        -- TODO put fnd_messages
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    if NOT l_phymed_found THEN
      BEGIN
        -- try at this site and ALL language
        ---dbms_output.put_line('try at this site and ALL language');

        -- modified by Guigen Zhang 04-04-2001 16:46
        select a.file_name, b.description, a.file_id
        into l_filename, l_description, l_fileid

        from
          jtf_amv_attachments a,
          jtf_amv_items_vl b,
          jtf_dsp_lgl_phys_map c
        where
          c.item_id = l_logid and
          c.msite_id = p_siteid  and
          c.default_site = 'N' and
          c.default_language = 'Y' and
          c.attachment_id = a.attachment_id and
          c.item_id = b.item_id and
          a.application_id = 671 and
          b.application_id = 671;
        l_phymed_found := TRUE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          -- TODO put fnd_messages
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      if NOT l_phymed_found THEN
        BEGIN
          -- try at ALL sites and ALL langauge
          ---dbms_output.put_line('try at ALL sites and ALL langauge');

          -- modified by Guigen Zhang 04-04-2001 16:46
          select a.file_name, b.description, a.file_id
            into l_filename, l_description, l_fileid

          from
            jtf_amv_attachments a,
            jtf_amv_items_vl b,
            jtf_dsp_lgl_phys_map c
          where
            c.item_id = l_logid and
            c.default_site = 'Y' and
            c.default_language = 'Y' and
            c.attachment_id = a.attachment_id and
            c.item_id = b.item_id and
            a.application_id = 671 and
            b.application_id = 671;
          -- dbms_output.put_line('all combos tried');
          -- dbms_output.put_line(l_filename);
          -- dbms_output.put_line(l_description);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_filename := NULL;
            x_description := NULL;

            -- modified by Guigen Zhang 04-04-2001 16:46
            x_fileid := NULL;

            RETURN;
          WHEN OTHERS THEN
            -- TODO put fnd_messages
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
      END IF;
    END IF;
  END IF;

  ---dbms_output.put_line('done both log and phy');
  -- return the filename and description
  x_filename := l_filename;
  x_description := l_description;

  -- modified by Guigen Zhang 04-04-2001 16:46
  x_fileid := l_fileid;

  ---dbms_output.put_line('just before returning');
  -- RETURN;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data);

END get_media;

END JTF_PHY_MEDIA_PVT ;

/
