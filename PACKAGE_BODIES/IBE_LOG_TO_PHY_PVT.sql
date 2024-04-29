--------------------------------------------------------
--  DDL for Package Body IBE_LOG_TO_PHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_LOG_TO_PHY_PVT" AS
/* $Header: IBEVDPOB.pls 115.1 2002/12/14 07:53:34 schak ship $ */
G_PKG_NAME  CONSTANT VARCHAR2(21):= 'IBE_LOG_TO_PHY_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVDPOB.pls';
-- ****************************************************************************
-- get physical object given logical id, site id and language code
-- ****************************************************************************
PROCEDURE get_obj_by_id(
  p_api_version         IN   NUMBER,
  p_init_msg_list 	IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT NOCOPY VARCHAR2,
  x_msg_count   	OUT NOCOPY NUMBER,
  x_msg_data  		OUT NOCOPY VARCHAR2,
  p_logicalid           IN ibe_dsp_obj_lgl_ctnt.item_id%TYPE,
  p_siteid 		IN ibe_dsp_lgl_phys_map.msite_id%TYPE,
  p_langcode            IN ibe_dsp_lgl_phys_map.language_code%TYPE,
  x_filename    	OUT NOCOPY jtf_amv_attachments.file_name%TYPE,
  x_description 	OUT NOCOPY jtf_amv_items_vl.description%TYPE,

  -- added by Guigen Zhang 04-04-2001 16:46
  x_fileid              OUT NOCOPY jtf_amv_attachments.file_id%TYPE) IS

  l_filename jtf_amv_attachments.file_name%TYPE;
  l_description jtf_amv_items_vl.description%TYPE := 'description';

  -- added by Guigen Zhang 04-04-2001 16:46
  l_fileid jtf_amv_attachments.file_id%TYPE;

  l_logid ibe_dsp_obj_lgl_ctnt.item_id%TYPE;
  l_api_name CONSTANT varchar2(30) := 'get_obj_by_id';
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

  l_logid := p_logicalid;

  BEGIN
    -- logical media has been found, get the physical media
    -- first try at the site and language
    ---dbms_output.put_line(' logical media logical id is ' || l_logid);
    ---dbms_output.put_line(' try physical at the site and language');

    -- modified by Guigen Zhang 04-04-2001 16:46
    select a.file_name, b.description, a.file_id
      into l_filename, l_description, l_fileid
    from
      jtf_amv_attachments a,
      jtf_amv_items_vl b,
      ibe_dsp_lgl_phys_map c
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
        ibe_dsp_lgl_phys_map c
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
          ibe_dsp_lgl_phys_map c
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
            ibe_dsp_lgl_phys_map c
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

            -- added by Guigen Zhang 04-04-2001 16:46
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

END get_obj_by_id;

-- ****************************************************************************
-- get physical object given access name, site id and language code
-- ****************************************************************************
PROCEDURE GET_OBJ_BY_NAME(
  p_api_version         IN   NUMBER,
  p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_access_name          IN jtf_amv_items_vl.access_name%TYPE,
  p_siteid              IN  ibe_dsp_lgl_phys_map.msite_id%TYPE,
  p_langcode            IN  ibe_dsp_lgl_phys_map.language_code%TYPE,
  x_filename            OUT NOCOPY jtf_amv_attachments.file_name%TYPE,
  x_description         OUT NOCOPY jtf_amv_items_vl.description%TYPE,

  -- added by Guigen Zhang 04-04-2001 16:46
  x_fileid              OUT NOCOPY jtf_amv_attachments.file_id%TYPE) IS

  l_filename jtf_amv_attachments.file_name%TYPE;
  l_description jtf_amv_items_vl.description%TYPE := 'description';

  -- added by Guigen Zhang 04-04-2001 16:46
  l_fileid jtf_amv_attachments.file_id%TYPE;

  l_accessname jtf_amv_items_vl.access_name%TYPE;
  l_api_name CONSTANT varchar2(30) := 'get_obj_by_name';
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

  l_accessname := p_access_name;

  BEGIN
    -- logical media has been found, get the physical media
    -- first try at the site and language
    ---dbms_output.put_line(' logical media logical id is ' || l_accessname);
    ---dbms_output.put_line(' try physical at the site and language');

    -- modified by Guigen Zhang 04-04-2001 16:46
    select a.file_name, b.description, a.file_id
      into l_filename, l_description, l_fileid

    from
      jtf_amv_attachments a,
      jtf_amv_items_vl b,
      ibe_dsp_lgl_phys_map c
    where
      b.access_name = l_accessname and
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
        ibe_dsp_lgl_phys_map c
      where
        b.access_name = l_accessname and
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
          ibe_dsp_lgl_phys_map c
        where
          b.access_name = l_accessname and
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
            ibe_dsp_lgl_phys_map c
          where
            b.access_name = l_accessname and
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

END GET_OBJ_BY_NAME;

END IBE_LOG_TO_PHY_PVT;

/
