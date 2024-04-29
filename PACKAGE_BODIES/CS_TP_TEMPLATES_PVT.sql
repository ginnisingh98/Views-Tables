--------------------------------------------------------
--  DDL for Package Body CS_TP_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_TP_TEMPLATES_PVT" as
/* $Header: cstptmmb.pls 120.0 2005/06/01 10:55:21 appldev noship $ */

/*============================================================================+
 |                Copyright (c) 1999 Oracle Corporation                       |
 |                   Redwood Shores, California, USA                          |
 |                        All rights reserved.                                |
 +============================================================================+
 | History                                                                    |
 |        Created by nazhou.                                                  |
 |  30-APR-2002 KLOU                                                          |
 |              1. Fix problem in show_templates_with_link that when          |
 |                 only urgency profile is turn on, a sql "invalid            |
 |                 column" exception is thrown.                               |
 |  23-Sep-2002 WMA                                                           |
 |              2. Tune up the performance for querying the link              |
 |  115.41   03-DEC-2002 WZLI changed OUT and IN OUT calls to use NOCOPY hint |
 |                           to enable pass by reference.                     |
 |  115.42   05-FEB-2003 WMA                                                  |
 |           Add four more new APIS                                           |
 |           Show_template_links_Two                                          |
 |           Show_Non_Asso_Links_TWo                                          |
 |           Delete_Template_Link                                             |
 |           Add_Template_Link                                                |
 |  115.43   26-FEB-2003  WMA                                                 |
 |           In produce Show_Link_attribute_list                              |
 |           if the first character of the arrtibute name (l_name) is space   |
 |           remove it( 2824600)                                              |
 |  115.44   01-FEB-2004 WMA                                                  |
 |           change the template ID and jtf_code to be dynamically bind       |
 |           in procedure Show_template_attributes.                           |
 |  115.45   13-OCT-2004 WMA                                                  |
 |           change procedure show_template_non_asso_links_two for performance|
 |           tuning.                                                          |
 |  115.46   18-APR-2005  WMA                                                 |
 |           Handle the date format issue, change the literal queries.        |
 |           it is copied from version: 115.44.11510.4.                       |
 +============================================================================*/
-- ---------------------------------------------------------
-- Define global variables and types
-- ---------------------------------------------------------
 l_default_last_up_date_format   CONSTANT  VARCHAR2(30)   := 'MM/DD/YYYY/SSSSS';
 G_PKG_NAME                      CONSTANT  VARCHAR2(100)  := 'CS_TP_TEMPLATE_PVT';

 l_default_update_format2 VARCHAR2(100) := '';

FUNCTION get_user_id RETURN NUMBER AS
  BEGIN
        Return FND_GLOBAL.USER_ID;
END get_user_id;

FUNCTION get_date_format_from_user(p_user_id IN NUMBER)
   RETURN VARCHAR2  AS
BEGIN
    -- get the default date format for this user
    Return FND_PROFILE.VALUE_SPECIFIC(
              'ICX_DATE_FORMAT_MASK',
              p_user_id,
              null,
              null);
EXCEPTION
   WHEN OTHERS THEN
      RETURN 'MON-DD-YYYY';  -- use this one as default
END get_date_format_from_user;

FUNCTION get_date_format_from_user_two
   RETURN VARCHAR2  AS
   p_user_id     NUMBER;
   p_format      varchar2(100) := null;
BEGIN
    p_user_id  := get_user_id;
    -- get the default date format for this user
    p_format := FND_PROFILE.VALUE_SPECIFIC(
              'ICX_DATE_FORMAT_MASK',
              p_user_id,
              null,
              null);
    if( p_format is null or p_format = '') then
       p_format := 'MON-DD-YYYY';
    end if;

    return p_format;

EXCEPTION
   WHEN OTHERS THEN
      RETURN 'MON-DD-YYYY';  -- use this one as default
END get_date_format_from_user_two;


-- This function is temporaly fixed for the UAT env
-- This function is unified with Calender_date_format
-- later the date format should be read from the user-profile
FUNCTION get_calender_date_format RETURN VARCHAR2 AS
BEGIN
    Return 'DD-MON-RRRR';
END get_calender_date_format;

FUNCTION get_date_format RETURN VARCHAR2 AS
BEGIN
       RETURN get_calender_date_format;
END get_date_format;

PROCEDURE check_attribute_error (
    p_template_attributes    IN  template_attribute_list,
    x_return_status          Out NOCOPY varchar2)
IS
    sorted_list      template_attribute_list;
    temp_attribute   template_attribute;
    i                number;
    j                number;
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  sorted_list     := p_template_attributes;

  for i in sorted_list.first..(sorted_list.last-1) loop
    for j in sorted_list.first..(sorted_list.last-1) loop
      if (sorted_list(j+1).mendthreshold < sorted_list(j).mendthreshold) then
           temp_attribute := sorted_list(j+1);
           sorted_list(j+1):= sorted_list(j);
           sorted_list(j):= temp_attribute;
      end if;
    end loop;
  end loop;
  for i in sorted_list.first..(sorted_list.last-1) loop
    if (sorted_list(i).mstartthreshold >  g_attr_max_threshold or
        sorted_list(i).mstartthreshold <  g_attr_min_threshold or
        sorted_list(i).mendthreshold   >  g_attr_max_threshold or
        sorted_list(i).mendthreshold   < g_attr_min_threshold  or
        sorted_list(i).mstartthreshold > sorted_list(i).mendthreshold ) then
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('cs','CS_TP_TEMPLATE_ATTR_THRESH');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
     elsif (sorted_list(i).mstartthreshold=0 and sorted_list(i).mendthreshold=0) then
          null;
     elsif (sorted_list(i).mendthreshold >= sorted_list(i+1).mstartthreshold) then
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('CS','CS_TP_TEMPLATE_ATTR_THRESH');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_error;
      end if;
  end loop;
  -- Check the last element
  if (sorted_list(sorted_list.last).mstartthreshold >  g_attr_max_threshold or
      sorted_list(sorted_list.last).mstartthreshold < g_attr_min_threshold  or
      sorted_list(sorted_list.last).mendthreshold   >  g_attr_max_threshold or
      sorted_list(sorted_list.last).mendthreshold   < g_attr_min_threshold  or
      sorted_list(sorted_list.last).mstartthreshold > sorted_list(sorted_list.last).mendthreshold ) then
           x_return_status := fnd_api.g_ret_sts_error;
           fnd_message.set_name('CS','CS_TP_TEMPLATE_ATTR_THRESH');
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
  end if;
end  Check_Attribute_Error;

-- ---------------------------------------------------------
-- Define public procedures
-- ---------------------------------------------------------
-- *****************************************************************************
-- Start of Comments
--   This procedure Add_Template Add an additional template to the CS_TP_Templates_B Table
--   The user needs to pass in a template record which holds the template attributes.
--   User can leave the template id and last_updated_date field  in the template
--   record blank.  However, user needs to pass in the rest of the fields in
--   the template record.  In addition, the mEndDate must be later than mStartDate
--
--   @param  p_one_template         required
--   @param  p_api_version_number   required
--   @param p_commit
--   @param  p_init_msg_list

--   @return x_template_id
--           x_msg_count
--           x_msg_data
--           x_return_status
--   Changed by KLOU, 05/01/2002
--   1. Remove the Begin-End block when mEndDate < mStartDate. Instead, raise exception
--      directly.
--   2. When mDefaultFlag is null, set it to 'F' instead of raising exception.
--
-- End of Comments
PROCEDURE Add_Template  (
          p_api_version_number     IN   NUMBER,
          p_init_msg_list          IN   VARCHAR2   := FND_API.G_FALSE,
          p_commit                 IN   VARCHAR    := FND_API.G_FALSE,
          p_one_template           IN   TEMPLATE,
          x_msg_count              OUT NOCOPY  NUMBER,
          x_msg_data               OUT NOCOPY  VARCHAR2,
          x_return_status          OUT NOCOPY  VARCHAR2,
          x_template_id            OUT NOCOPY  NUMBER)

IS
        l_api_name     CONSTANT       VARCHAR2(30)   := 'Add_Template';
        l_api_version  CONSTANT       NUMBER         := 1.0;
        l_template_id                 NUMBER         := FND_API.G_MISS_NUM;
        l_current_date                DATE           := FND_API.G_MISS_DATE;
        l_created_by                  NUMBER         := FND_API.G_MISS_NUM;
        l_login                       NUMBER         := FND_API.G_MISS_NUM;
        l_rowid                       VARCHAR2(100);
        l_date_format                 VARCHAR2(100);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    if fnd_api.to_boolean( p_init_msg_list ) then
        fnd_msg_pub.initialize;
    end if;

    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

    -- Start API Body
    -- Perform validation

    --l_date_format := get_date_format;
    l_date_format := get_date_format_from_user_two;

    if  p_one_template.mtemplatename is null or
        p_one_template.mtemplatename = fnd_api.g_miss_char then
       x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('CS','CS_TP_TEMPLATE_NAME_INVALID');
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
    end if;

   if (to_date(p_one_template.mEndDate, l_date_format))
      < (to_date(p_one_template.mStartDate, l_date_format)) then
         --incorrect date format, raise generic exception
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name('CS','CS_TP_TEMPLATE_DATE_INVALID');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
   end if;

    --Get the template id from the next available sequence number
    select cs_tp_templates_s.nextval into l_template_id from dual;

    l_current_date := sysdate;
    l_created_by   := fnd_global.user_id;
    l_login        := fnd_global.login_id;

    CS_TP_TEMPLATES_PKG.INSERT_ROW (
          x_rowid             => l_rowid,
          x_template_id       => l_template_id,
          x_default_flag      => nvl(p_one_template.mDefaultFlag, 'F'),
          x_start_date_active => to_date (p_one_template.mStartDate, l_date_format),
          x_end_date_active   => to_date (p_one_template.mEndDate, l_date_format),
          x_name              => p_one_template.mTemplateName,
          x_description       => null,
          x_creation_date     => l_current_date,
          x_created_by        => l_created_by,
          x_last_update_date  => l_current_date,
          x_last_updated_by   => l_created_by,
          x_last_update_login => l_login,
          x_attribute1        => p_one_template.mShortCode,
          x_uni_question_note_flag => p_one_template.mUniquestionNoteFlag,
          x_uni_question_note_type => p_one_template.mUniquestionNoteType);

   x_template_id := l_template_id;

   if fnd_api.to_boolean( p_commit ) then
          commit work;
   end if;
   Fnd_Msg_Pub.Count_And_Get(
         p_count => x_msg_count ,
         p_data  => x_msg_data );
END Add_Template;

-- *****************************************************************************
-- Start of Comments
--
-- Delete Template will delete the template with the passed in template id in the CS_TP_Templates_B and CS_TP_Templates_TL table with the passed in P_Template_ID
--
-- An exception will be raised if the template with passed in templated id cannot be found
-- @param  P_Template_ID          required
-- @param  p_api_version_number   required
-- @param       p_commit
-- @param  p_init_msg_list
-- @return  x_msg_count
--          x_msg_data
--          x_return_status
--
-- End of Comments
PROCEDURE Delete_Template (
  p_api_version_number     IN  NUMBER,
  p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                 IN  VARCHAR   := FND_API.G_FALSE,
  p_template_id            IN  NUMBER,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2)
IS
  l_api_name     CONSTANT VARCHAR2(30):= 'Delete_Template';
  l_api_version  CONSTANT NUMBER      := 1.0;

BEGIN
  -- Initialize message list if p_init_msg_list is set to TRUE.
  If Fnd_Api.To_Boolean( p_init_msg_list ) Then
      Fnd_Msg_Pub.Initialize;
  End If;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  CS_TP_TEMPLATES_PKG.DELETE_ROW (P_Template_ID);

  -- Standard check of p_commit.
  If Fnd_Api.To_Boolean( p_commit ) Then
      Commit Work;
  End If;

  Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count ,
                            p_data  => x_msg_data);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data);
    Raise;
END Delete_Template;

-- *****************************************************************************
-- Start of Comments
--
-- Update Template will update the template with a specific template id  in the CS_TP_Templates_B and CS_TP_Templates_TL table with the new template attributes.
-- All fields inside the template are required
-- An exception is raised if template with template id cannot be found
-- @param  P_One_Template   required
-- @param  p_api_version_number   required
-- @param       p_commit
-- @param  p_init_msg_list

-- @return  x_msg_count
--          x_msg_data
--          x_return_status
--
-- End of Comments
-- *****************************************************************************

PROCEDURE Update_Template (
  p_api_version_number IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2:= FND_API.G_FALSE,
  p_commit             IN  VARCHAR := FND_API.G_FALSE,
  p_one_template       IN  Template,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2)

IS
    l_api_name     CONSTANT  VARCHAR2(30):= 'Update_Template';
    l_api_version  CONSTANT  NUMBER      := 1.0;
    l_date_format            VARCHAR2(60):= FND_API.G_MISS_CHAR;
    l_last_updated_date      DATE;
    l_current_date           DATE        :=FND_API.G_MISS_DATE;
    l_last_updated_by        NUMBER      :=FND_API.G_MISS_NUM;
    l_login                  NUMBER      :=FND_API.G_MISS_NUM;
    CURSOR c IS
     Select last_update_date From CS_TP_TEMPLATES_B
        Where TEMPLATE_ID = p_one_template.mTemplateID;

BEGIN
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize;
  END IF;

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- Perform validation
  -- l_date_format := get_calender_date_format;

  l_date_format := get_date_format_from_user_two;
  IF(nvl(p_one_template.mTemplateName,fnd_api.g_miss_char)=fnd_api.g_miss_char) THEN
     X_Return_Status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_NAME_INVALID');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (nvl(P_One_Template.mDefaultFlag,fnd_api.g_miss_char)=fnd_api.g_miss_char) THEN
     X_Return_Status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ATTR_INVALID');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF TO_DATE(P_One_Template.mEndDate, l_date_format)
    < TO_DATE (P_One_Template.mStartDate, l_date_format) THEN
      X_Return_Status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_DATE_INVALID');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  --check to see if the template is modified after the client's query
  Open c;
  Fetch c Into l_last_updated_date;
  If (c%notfound) Then
    Close c;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ID_INVALID');
    FND_MSG_PUB.Add;
    Raise no_data_found;
  End If;
  Close c;

  If (P_One_Template.mLast_Updated_Date Is Null
      OR length(P_One_Template.mLast_Updated_Date) <=0
      OR P_One_Template.mLast_Updated_Date = FND_API.G_MISS_CHAR) then
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('CS','CS_TP_LASTUPDATE_DATE_NULL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  End If;

  l_default_update_format2 :=
    get_date_format_from_user_two||' HH24:MI:SS';
 -- is the last updated date from db later than the date from client
  If (l_last_updated_date >
     to_date(P_One_Template.mLast_Updated_Date, l_default_update_format2)) Then
        X_Return_Status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_UPDATED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
  End If;

  l_current_date    := sysdate;
  l_last_updated_by := fnd_global.user_id;
  l_login           := fnd_global.login_id;

  CS_TP_TEMPLATES_PKG.Update_Row (
    x_template_id            => P_One_Template.mTemplateID,
    x_default_flag           => P_One_Template.mDefaultFlag,
    x_start_date_active      => TO_DATE (P_One_Template.mStartDate, l_date_format),
    x_end_date_active        => TO_DATE (P_One_Template.mEndDate, l_date_format),
    x_name                   => P_One_Template.mTemplateName,
    x_description            => NULL,
    x_last_update_date       => l_current_date,
    x_last_updated_by        => l_last_updated_by,
    x_last_update_login      => l_login,
    x_attribute1             => P_One_Template.mShortCode,
    x_uni_question_note_flag => P_One_Template.mUniQuestionNoteFlag,
    x_uni_question_note_type => P_One_Template.mUniQuestionNoteType );

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count ,
                           p_data => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count ,
                              p_data => x_msg_data);
END Update_Template;

PROCEDURE Update_Template_Attributes  (
  p_api_version_number   IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit               IN  VARCHAR   := FND_API.G_FALSE,
  p_template_id          IN  NUMBER,
  p_template_attributes  IN  Template_Attribute_List,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2)
IS
  l_api_name     CONSTANT       VARCHAR2(30)  := 'Update_Template_Attributes';
  l_api_verion   CONSTANT       NUMBER        := 1.0;
  l_template_count_with_id     NUMBER;
  l_stmt                        VARCHAR2(210);
  l_JTF_OBJECT_CursorID         NUMBER;
  l_JTF_OBJECT_CODE_count       NUMBER;
  l_ROW_ID                      VARCHAR2(30);
  l_current_date                DATE          :=FND_API.G_MISS_DATE;
  l_created_by                  NUMBER        :=FND_API.G_MISS_NUM;
  l_login                       NUMBER        :=FND_API.G_MISS_NUM;
  l_last_updated_date           DATE;
  l_attribute_id            NUMBER;

  CURSOR C IS
     Select count(*) From cs_tp_templates_b;

  CURSOR Last_Updated_Date_C (v_template_id     NUMBER,
                              v_other_id        NUMBER,
                              v_jtf_object_code VARCHAR2) IS
     Select last_update_date
     From cs_tp_template_attribute
     where  template_id = v_template_id
     and    other_id    = v_other_id
     and    object_code = v_jtf_object_code;

  l_One_Template_Attribute      Template_Attribute;

BEGIN
  -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

    -- perform validation, see if template id is valid
    OPEN C;
    FETCH C INTO l_template_count_with_id;
    IF (l_template_count_with_id <=0 ) THEN
         CLOSE C;
         X_Return_Status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE C;

   -- perform attribute error checking
   Check_Attribute_Error (P_Template_Attributes, X_Return_Status);

   /* Logic:
      Loop through each attribute.  If the attribute id is present,
      perform update the record. Otherwise, insert into the cs_tp_template_attribute
      table
   */
  FOR i IN P_Template_Attributes.FIRST..P_Template_Attributes.LAST LOOP

   l_One_Template_Attribute := P_Template_Attributes (i);
    If (nvl(l_One_Template_Attribute.mAttributeName,FND_API.G_MISS_CHAR)
         = FND_API.G_MISS_CHAR) Then
         X_Return_Status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ATTR_NAME');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
    End If;

    If (l_One_Template_Attribute.mAttributeID is not NULL
      and  l_One_Template_Attribute.mAttributeID <> FND_API.G_MISS_NUM
      and (l_One_Template_Attribute.mLast_Updated_Date is NULL
           OR l_One_Template_Attribute.mLast_Updated_Date =
           FND_API.G_MISS_CHAR)) Then
       X_Return_Status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CS','CS_TP_TEM_AT_LUPD_NULL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    End If;

    --check to see if the row is updated or inserted after the user queries the
    --template attribute
    Open Last_Updated_Date_C(P_Template_ID,
                             l_One_Template_Attribute.mOther_ID,
                             l_One_Template_Attribute.mJTF_OBJECT_CODE);
    Fetch Last_Updated_Date_C Into l_last_updated_date;

    If (Last_Updated_Date_C%Notfound) Then
       Close Last_Updated_Date_C;
    Elsif (l_One_Template_Attribute.mAttributeID Is Null
      OR l_One_Template_Attribute.mAttributeID = FND_API.G_MISS_NUM) Then
    -- row is  already inserted
       X_Return_Status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ATTR_UPDATED');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    Elsif (l_last_updated_date >
        TO_DATE (l_One_Template_Attribute.mLast_Updated_Date,
          l_default_last_up_date_format ))
      Then
    -- row is already updated
       X_Return_Status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ATTR_UPDATED');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    End If;
    If (Last_Updated_Date_C%ISOPEN) Then
       Close Last_Updated_Date_C;
    End If;

    l_current_date := sysdate;
    l_created_by   := FND_GLOBAL.user_id;
    l_login        := fnd_global.login_id;

    If (l_One_Template_Attribute.mAttributeID is NULL
     OR l_One_Template_Attribute.mAttributeID = FND_API.G_MISS_NUM) Then
    -- need to insert into the Attribute Table
        Select CS_TP_TEMPLATE_ATTRIBUTE_S.NextVal Into l_attribute_id From dual;

        CS_TP_TEMPLATE_ATTRIBUTE_PKG.INSERT_ROW (
          x_rowid                 => l_Row_ID ,
          x_template_attribute_id => l_attribute_id,
          x_template_id           => P_Template_ID,
          x_other_id              => l_One_Template_Attribute.mOther_ID,
          x_object_code           => l_One_Template_Attribute.mJTF_OBJECT_CODE,
          x_start_threshold       => l_One_Template_Attribute.mStartThreshold,
          x_end_threshold         => l_One_Template_Attribute.mEndThreshold,
          x_attribute1            => l_One_Template_Attribute.mDefaultFlag,
          x_creation_date         => l_current_date,
          x_created_by            => l_created_by,
          x_last_update_date      => l_current_date,
          x_last_updated_by       => l_created_by,
          x_last_update_login     => l_login);
    Else
        CS_TP_TEMPLATE_ATTRIBUTE_PKG.UPDATE_ROW (
          x_template_attribute_id => l_One_Template_Attribute.mAttributeID,
          x_template_id           => P_Template_ID,
          x_other_id              => l_One_Template_Attribute.mOther_ID,
          x_object_code           => l_One_Template_Attribute.mJTF_OBJECT_CODE,
          x_start_threshold       => l_One_Template_Attribute.mStartThreshold,
          x_end_threshold         => l_One_Template_Attribute.mEndThreshold,
          x_attribute1            => l_One_Template_Attribute.mDefaultFlag,
          x_last_update_date      => l_current_date,
          x_last_updated_by       => l_created_by,
          x_last_update_login     => l_login);
     End If;
  END LOOP;

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count ,
                           p_data => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                               p_data  => x_msg_data);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
    END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                                 p_data  => x_msg_data);
    RAISE;
END  Update_Template_Attributes;

PROCEDURE Update_Template_Links (
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR   := FND_API.G_FALSE,
    p_template_id            IN  NUMBER,
    p_jtf_object_code        IN  VARCHAR2,
    p_template_links         IN  Template_Link_List,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2)
IS
  TYPE l_Need_To_Be_Delete_List_type is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_api_name     CONSTANT       VARCHAR2(30) := 'Update_Template_Links';
  l_api_version  CONSTANT       NUMBER       := 1.0;
  l_JTF_OBJECT_CursorID         NUMBER;
  l_JTF_OBJECT_CODE_count       NUMBER;
  l_current_date                DATE         :=FND_API.G_MISS_DATE;
  l_created_by                  NUMBER       :=FND_API.G_MISS_NUM;
  l_login                       NUMBER       :=FND_API.G_MISS_NUM;
  l_Row_ID                      VARCHAR2(30);
  l_New_Link_id                  NUMBER;
  l_One_Template_Link           Template_Link;
  l_Need_To_Be_Delete_List      l_Need_To_Be_Delete_List_type;
  l_template_count_with_id      NUMBER;
  l_stmt                        VARCHAR2(100);
  i                             NUMBER;
  CURSOR C IS
     Select count(*)
     From CS_TP_TEMPLATES_B
     Where template_id = P_Template_ID;
  CURSOR Need_To_Be_Delete_Cursor (v_current_date DATE) IS
     Select link_id
     From CS_TP_TEMPLATE_LINKS
     Where template_id = P_Template_ID
     and  OBJECT_CODE =  P_JTF_OBJECT_CODE
     and  last_update_date < v_current_date  ;
BEGIN
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- perform validation, see if template id is valid
  Open C;
  Fetch C Into l_template_count_with_id;
  If (l_template_count_with_id <=0 ) Then
       Close C;
        X_Return_Status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_Link_TID_INV');
        FND_MSG_PUB.Add;
       Raise FND_API.G_EXC_ERROR  ;
  End If;
  Close C;
  l_current_date := sysdate;
  l_created_by   := fnd_global.user_id;
  l_login        := fnd_global.login_id;

  --loop through each link.  If the link id is present, perform an update.
  If (P_Template_Links.COUNT >0) Then
    For i In P_Template_Links.FIRST..P_Template_Links.LAST Loop
      l_One_Template_Link := P_Template_Links (i);
      -- If the link_id is passed, modify the row, otherwise insert the row.
      -- After insertion and modifying, delete the rows that have not be inserted
      -- or modified in the table

      If (l_One_Template_Link.mLinkID Is Null
        Or l_One_Template_Link.mLinkID = FND_API.G_MISS_NUM) Then

        --Get the template id from the next available sequence number
        Select CS_TP_TEMPLATE_LINKS_S.nextval Into l_New_Link_id From dual;
        CS_TP_TEMPLATE_LINKS_PKG.INSERT_ROW (
               x_rowid              => l_Row_ID ,
               x_link_id            => l_New_Link_id,
               x_template_id        => P_Template_ID,
               x_other_id           => l_One_Template_Link.mOther_ID,
               x_lookup_code        => l_One_Template_Link.lookup_Code,
               x_lookup_type        => l_One_Template_Link.Lookup_Type,
               x_object_code        => l_One_Template_Link.mJTF_OBJECT_CODE,
               x_creation_date      => l_current_date,
               x_created_by         => l_created_by,
               x_last_update_date   => l_current_date,
               x_last_updated_by    => l_created_by,
               x_last_update_login  => l_login);
      Else
        CS_TP_TEMPLATE_LINKS_PKG.UPDATE_ROW (
               x_link_id            => l_One_Template_Link.mLinkID,
               x_template_id        => P_Template_ID,
               x_other_id           => l_One_Template_Link.mOther_ID,
               x_lookup_code        => l_One_Template_Link.lookup_Code,
               x_lookup_type        => l_One_Template_Link.Lookup_Type,
               x_object_code        => l_One_Template_Link.mJTF_OBJECT_CODE,
               x_last_update_date   =>l_current_date,
               x_last_updated_by    => l_created_by,
               x_last_update_login  => l_login);


        End If;
      End loop;
   End If;  --P_Template_Links.count>0

   -- now delete the rows that are neither updated nor inserted
    i:=0;
    Open Need_To_Be_Delete_Cursor(l_current_date);
    Loop
      Fetch Need_To_Be_Delete_Cursor Into l_Need_To_Be_Delete_List(i);
      Exit When (Need_To_Be_Delete_Cursor%notfound);
      i:=i+1;
    End Loop;
    Close Need_To_Be_Delete_Cursor;

    If (l_Need_To_Be_Delete_List.COUNT > 0) Then
      For i In l_Need_To_Be_Delete_List.FIRST..l_Need_To_Be_Delete_List.LAST Loop
         CS_TP_TEMPLATE_LINKS_PKG.DELETE_ROW
              ( X_LINK_ID =>l_Need_To_Be_Delete_List(i));
      End Loop;
    End If;

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data);
END Update_Template_Links;


PROCEDURE Show_Templates  (
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
    P_Template_Name          IN  VARCHAR2,
    P_Start_Template         IN  NUMBER,
    P_End_Template           IN  NUMBER,
    P_Display_Order          IN  VARCHAR2,
    X_Msg_Count              OUT NOCOPY NUMBER,
    X_Msg_Data               OUT NOCOPY VARCHAR2,
    X_Return_Status          OUT NOCOPY VARCHAR2,
    X_Template_List_To_Show  OUT NOCOPY Template_List,
    X_Total_Templates        OUT NOCOPY NUMBER,
    X_Retrieved_Template_Num OUT NOCOPY NUMBER  )
IS
    l_api_name     CONSTANT       VARCHAR2(30) := 'Show_Templates';
    l_api_version  CONSTANT       NUMBER       := 1.0;
    l_statement                   VARCHAR2(1000);
    l_template_id                 NUMBER;
    l_template_name               VARCHAR2(500);
    l_start_date_active           DATE;
    l_end_date_active             DATE;
    l_default_flag                VARCHAR2(60);
    l_short_code                  VARCHAR2(150);
    l_date_format                 VARCHAR2(60) := FND_API.G_MISS_CHAR;
    l_cursorid                    INTEGER;
    l_last_updated_date            DATE;
    i                             NUMBER;
    j                             NUMBER;
    l_total_templates_notused     NUMBER;
    l_start_template              NUMBER;
    l_end_template                NUMBER;
    l_uni_question_note_flag      VARCHAR2(1);
    l_uni_question_note_type      VARCHAR2(30);

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_start_template := P_Start_Template;
    l_end_template   := P_End_Template;

    -- Check for null L_Start_Template and P_End_Template
    If (l_start_template Is Null
      Or l_start_template = FND_API.G_MISS_NUM) Then
       l_start_template := 1;
    End If;

    -- If L_End_Template is NULL, set it to G_MISS_NUM
    -- which should be a greater than any template number
    If (l_end_template Is Null
      Or l_end_template = FND_API.G_MISS_NUM) then
       L_End_Template := FND_API.G_MISS_NUM;
    End If;

    -- validation
    If (l_start_template > l_end_template
      Or l_start_template <= 0 Or l_end_template <= 0) Then
       X_Return_Status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_INQUIRY_INVALID');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    End If;

  -- Construct query statement, open cursor, execute query statement, retrieve results
    l_statement := ' SELECT
                     T.TEMPLATE_ID,
                     T.NAME,
                     T.START_DATE_ACTIVE,
                     T.END_DATE_ACTIVE,
                     T.DEFAULT_FLAG,
                     T.LAST_UPDATE_DATE,
                     T.ATTRIBUTE1,
                     T.UNI_QUESTION_NOTE_FLAG,
                     T.UNI_QUESTION_NOTE_TYPE  ' ||
                     ' FROM CS_TP_TEMPLATES_VL T  ';
    If (p_template_name Is Not Null
      and p_template_name <> FND_API.G_MISS_CHAR
      and length(P_Template_Name) > 0) Then
         l_statement := l_statement ||
                        ' WHERE UPPER(T.NAME) like UPPER(:v_Template_Name) ';
    End If;

    If (p_display_order Is  Null
      or p_display_order = FND_API.G_MISS_CHAR
      or length(P_Display_Order)<= 0
      or P_Display_Order =NORMAL) Then
         l_statement := l_statement || ' ORDER BY T.LAST_UPDATE_DATE ';
    Elsif (p_display_order=ALPHABATICAL) Then
        l_statement := l_statement || ' ORDER BY T.NAME ';
    Elsif (p_display_order = REVERSE_ALPHABATICAL) Then
        l_statement := l_statement || ' ORDER BY T.NAME desc ';
    Elsif (p_display_order = CRONOLOGICAL) Then
        l_statement := l_statement || ' ORDER BY T.LAST_UPDATE_DATE ';
    Elsif (p_display_order = REVERSE_CRONOLOGICAL) Then
        l_statement := l_statement || ' ORDER BY T.LAST_UPDATE_DATE desc ';
    End If;

    -- Prepare dynamic sql statement
    l_CursorID := dbms_sql.open_cursor;

    dbms_sql.parse(l_CursorID, l_statement, dbms_sql.NATIVE);
    dbms_sql.define_column(l_CursorID, 1, l_template_id);
    dbms_sql.define_column(l_CursorID, 2, l_template_name,500);
    dbms_sql.define_column(l_CursorID, 3, l_start_date_active);
    dbms_sql.define_column(l_CursorID, 4, l_end_date_active);
    dbms_sql.define_column(l_CursorID, 5, l_default_flag, 60);
    dbms_sql.define_column(l_CursorID, 6, l_last_updated_date);
    dbms_sql.define_column(l_CursorID, 7, l_short_code, 150);
    dbms_sql.define_column(l_CursorID, 8, l_uni_question_note_flag,1);
    dbms_sql.define_column(l_CursorID, 9, l_uni_question_note_type, 30);

    If (p_template_name Is Not Null
     and p_template_name <> FND_API.G_MISS_CHAR
     and length(P_Template_Name) > 0) Then
         dbms_sql.bind_variable(l_CursorID, 'v_Template_Name', P_Template_Name);
    End If;

    l_total_templates_notused := dbms_sql.execute(l_CursorID);

    i:=1;
    j:=0;
    --l_date_format := get_date_format;
    l_date_format := get_date_format_from_user_two;
    l_default_update_format2 :=
      get_date_format_from_user_two||' HH24:MI:SS';
    While (dbms_sql.fetch_rows(l_CursorID) > 0) Loop
      If (i >= l_start_template and i <= l_end_template) Then
        dbms_sql.column_value(l_CursorID, 1, l_template_id);
        dbms_sql.column_value(l_CursorID, 2, l_template_name);
        dbms_sql.column_value(l_CursorID, 3, l_start_date_active);
        dbms_sql.column_value(l_CursorID, 4, l_end_date_active);
        dbms_sql.column_value(l_CursorID, 5, l_default_flag);
        dbms_sql.column_value(l_CursorID, 6, l_last_updated_date);
        dbms_sql.column_value(l_CursorID, 7, l_short_code);
        dbms_sql.column_value(l_CursorID, 8, l_uni_question_note_flag);
        dbms_sql.column_value(l_CursorID, 9, l_uni_question_note_type);

        x_template_list_to_show(j).mTemplateID   := l_template_id;
        x_template_list_to_show(j).mTemplateName := l_template_name;
        x_template_list_to_show(j).mShortCode    := l_short_code;
        x_template_list_to_show(j).mDefaultFlag  := l_default_flag;
        x_template_list_to_show(j).mLast_Updated_Date
          := to_char( l_last_updated_date, l_default_update_format2);
        x_template_list_to_show(j).mStartDate
              := to_char (l_start_date_active, l_date_format);
        x_template_list_to_show(j).mEndDate
              := to_char( l_end_date_active, l_date_format);
        x_template_list_to_show(j).mUniQuestionNoteFlag
            := l_UNI_QUESTION_NOTE_FLAG;
        x_template_list_to_show(j).mUniQuestionNoteType
            := l_UNI_QUESTION_NOTE_TYPE;

        j := j+1;
      Elsif (i > L_End_Template) Then
                   null;
      End If;
      i := i+1;
    End Loop;

    dbms_sql.close_cursor(l_CursorID);
    x_retrieved_template_num := j;
    x_total_templates        := i - 1;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                               p_data  => x_msg_data);
END Show_Templates;

PROCEDURE Show_Template (
    p_api_version_number IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit             IN  VARCHAR  := FND_API.G_FALSE,
    p_template_id        IN  NUMBER,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_template_to_show   OUT NOCOPY Template)
IS
    l_api_name     CONSTANT   VARCHAR2(30)   := 'Show_Template';
    l_api_version  CONSTANT   NUMBER         := 1.0;
    l_date_format             VARCHAR2(60)   := FND_API.G_MISS_CHAR;
    l_statement               VARCHAR2(1000);
    l_template_id             NUMBER;
    l_template_name           VARCHAR2(500);
    l_start_date_active       DATE;
    l_end_date_active         DATE;
    l_last_updated_date        DATE;
    l_default_flag            VARCHAR2(60);
    l_short_code              VARCHAR2(150);
    l_cursorid                NUMBER;
    l_total_templates_notused NUMBER;
    l_uni_question_note_flag  VARCHAR2(1);
    l_uni_question_note_type  VARCHAR2(30);

  Cursor l_tp_templates_csr ( tempId NUMBER ) Is
      Select  T.TEMPLATE_ID,
              T.NAME,
              T.START_DATE_ACTIVE,
              T.END_DATE_ACTIVE,
              T.DEFAULT_FLAG,
              T.LAST_UPDATE_DATE,
              T.ATTRIBUTE1,
              T.UNI_QUESTION_NOTE_FLAG,
              T.UNI_QUESTION_NOTE_TYPE
       From  CS_TP_TEMPLATES_VL T
      Where T.TEMPLATE_ID = tempId ;

    l_tp_template_rec l_tp_templates_csr%ROWTYPE;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

    -- Start API Body
    -- l_date_format := get_calender_date_format;
    l_date_format := get_date_format_from_user_two;
    l_default_update_format2 :=
      get_date_format_from_user_two||' HH24:MI:SS';

    Open l_tp_templates_csr ( P_Template_ID );
    Loop
      Fetch l_tp_templates_csr Into l_tp_template_rec;
      Exit When l_tp_templates_csr%NOTFOUND;
          x_template_to_show.mTemplateID   := l_tp_template_rec.TEMPLATE_ID;
          x_template_to_show.mTemplateName := l_tp_template_rec.NAME;
          x_template_to_show.mDefaultFlag  := l_tp_template_rec.DEFAULT_FLAG;
          x_template_to_show.mShortCode    := l_tp_template_rec.attribute1;
          x_template_to_show.mLast_Updated_Date
              := to_char( l_tp_template_rec.LAST_UPDATE_DATE,
                          l_default_update_format2);
          x_template_to_show.mStartDate
              := to_char (l_tp_template_rec.START_DATE_ACTIVE, l_date_format);
          x_template_to_show.mEndDate
              := to_char( l_tp_template_rec.END_DATE_ACTIVE, l_date_format);
          x_template_to_show.mUniQuestionNoteFlag
              := l_tp_template_rec.UNI_QUESTION_NOTE_FLAG;
          x_template_to_show.mUniQuestionNoteType
              := l_tp_template_rec.UNI_QUESTION_NOTE_TYPE;
    End Loop;
    Close l_tp_templates_csr;

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data
              );
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
           (p_count => x_msg_count ,
            p_data => x_msg_data
           );
   Raise;
END Show_Template;

PROCEDURE Show_Templates_With_Link (
        p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2   := FND_API.G_FALSE,
        p_commit                 IN   VARCHAR    := FND_API.G_FALSE,
        p_Object_Other_List      IN   OBJECT_OTHER_ID_PAIRS,
        X_Msg_Count              OUT NOCOPY  NUMBER,
        X_Msg_Data               OUT NOCOPY  VARCHAR2,
        X_Return_Status          OUT NOCOPY  VARCHAR2,
        X_Template_List          OUT NOCOPY  Template_List)
IS
  l_api_name     CONSTANT     VARCHAR2(30)   := 'Show_Templates_With_Link';
  l_api_version  CONSTANT     NUMBER         := 1.0;
  l_date_format               VARCHAR2(60)   := FND_API.G_MISS_CHAR;
  i                           NUMBER;
  l_CursorID                  NUMBER;
  l_total_attribute_num       NUMBER;
  Cursor_Statement            VARCHAR2(1000);
  L_TEMPLATE_ID               NUMBER;
  L_TEMPLATE_NAME             VARCHAR2(1000);
  L_START_DATE                DATE;
  L_END_DATE                  DATE;
  L_DEFAULT_FLAG              VARCHAR2(100);
  L_LAST_UPDATE_DATE          DATE;
  l_Short_Code                VARCHAR2(150);
  l_Cursor_Statement          VARCHAR2(2000);
  l_sel_template_from         VARCHAR2(500);
  l_sel_template_select       VARCHAR2(500);
  l_sel_template_where        VARCHAR2(500);
  l_sel_template_stmt         VARCHAR2(1500);
  firstOne                    NUMBER;
  profileValue                VARCHAR2(1);
  profileOn                   BOOLEAN;
  NoProfileOn                 BOOLEAN;
  needBind                    JTF_NUMBER_TABLE   := JTF_NUMBER_TABLE ();
  l_UNI_QUESTION_NOTE_FLAG    VARCHAR2(1);
  l_UNI_QUESTION_NOTE_TYPE    VARCHAR2(30);
BEGIN
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- Start API Body
  l_date_format := get_date_format;

  If (p_Object_Other_list Is Null Or p_Object_Other_list.COUNT <=0) Then
    Raise No_Data_Found;
  End If;

  l_sel_template_from := '';
  l_sel_template_where := null;

  --check to see whether the profile is on
  NoProfileOn := true;
  needBind.extend ( p_object_other_list.COUNT );

  firstOne := null; -- by klou 04/30/02

  For i In p_Object_Other_list.FIRST..p_Object_Other_list.last Loop
    profileOn := false;
    If  ( P_Object_Other_list(i).mOBJECT_CODE = 'IBU_PRODUCT' ) Then
      profileValue := fnd_profile.value ( 'IBU_SR_TP_SEARCH_PRODUCT' ) ;
      If ( profileValue Is Not Null And profileValue = 'Y' ) Then
        profileOn := true;
      End If;
    Elsif ( P_Object_Other_list(i).mOBJECT_CODE = 'IBU_PLATFORM' ) Then
      profileValue := fnd_profile.value ( 'IBU_SR_TP_SEARCH_PLATFORM' ) ;
      If ( profileValue is not null And profileValue = 'Y' ) Then
        profileOn := true;
      End If;
    Elsif ( P_Object_Other_list(i).mOBJECT_CODE = 'IBU_LINK_URGENCY' ) Then
      profileValue := fnd_profile.value ( 'IBU_SR_TP_SEARCH_URGENCY' ) ;
      If ( profileValue Is Not Null And profileValue = 'Y' ) Then
        profileOn := true;
      End If;
    Elsif ( P_Object_Other_list(i).mOBJECT_CODE = 'IBU_TP_SR_TYPE' ) Then
      profileValue := fnd_profile.value ( 'IBU_SR_TP_SEARCH_SR_TYPE' ) ;
      If ( profileValue Is Not Null And profileValue = 'Y' ) Then
        profileOn := true;
      End If;
    Elsif ( P_Object_Other_list(i).mOBJECT_CODE = 'IBU_TP_SR_PROBCODE' ) Then
      profileValue := fnd_profile.value ( 'IBU_SR_TP_SEARCH_PROB_CODE' ) ;
      If ( profileValue Is Not Null And profileValue = 'Y' ) Then
        profileOn := true;
      End If;
    End If;

    NoProfileOn := NoProfileOn and ( NOT profileOn);
    needBind ( i ) := 0;

    If ( profileOn ) Then
      needBind ( i ) := 1;
      If ( l_sel_template_where Is Null ) Then
            firstOne := i;
            l_sel_template_from := 'CS_TP_TEMPLATE_LINKS A' || i;
            If (P_Object_Other_list(i).mOBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
                l_sel_template_where := 'A' || i || '.OBJECT_CODE  = :v_Object_Code'
                                        || i || ' and ' ||'A' || i
                                        || '.OTHER_ID = :v_Other_ID' || i ;
            Else
                l_sel_template_where := 'A' || i || '.OBJECT_CODE  = :v_Object_Code'
                                        || i || ' and ' || 'A' || i
                                        || '.LOOKUP_CODE = :v_Other_Code' || i ;
            End If;
      Else
        l_sel_template_from := l_sel_template_from ||', CS_TP_TEMPLATE_LINKS A' || i;

        If(P_Object_Other_list(i).mOBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
          l_sel_template_where := l_sel_template_where || ' and ' ||'A' || i
                                  || '.OBJECT_CODE = :v_Object_Code' || i
                                  || ' and ' ||'A' || i || '.OTHER_ID = :v_Other_ID'
                                  || i || ' and ' || 'A' || i || '.TEMPLATE_ID = '
                                  || 'A' || firstOne || '.TEMPLATE_ID ';
        --p_Object_Other_list.FIRST
         Else
             If(P_Object_Other_list(i).mLOOKUP_CODE like 'NONE') Then
               l_sel_template_where := l_sel_template_where;
             Else
              l_sel_template_where := l_sel_template_where || ' and ' ||
                  'A' || i || '.OBJECT_CODE = :v_Object_Code' || i || ' and ' ||
                   'A' || i || '.LOOKUP_CODE = :v_Other_Code' || i || ' and ' ||
                  'A' || i || '.TEMPLATE_ID = ' || 'A' || firstOne || '.TEMPLATE_ID ';
            End If;
         End If; -- end P_Object_Other_list IF
      End If; -- end l_sel_template_where IF
    End If; -- end profileOn IF
  End Loop;

  IF NoProfileOn THEN
    Raise no_data_found;
  END IF;

  -- added by klou 04/30/02
  If firstOne Is Not Null Then
      l_sel_template_select := 'A' || firstOne || '.template_id';
  End If;

  l_sel_template_stmt := 'select ' || l_sel_template_select || ' from '
           || l_sel_template_from || ' where ' || l_sel_template_where ;
  l_Cursor_Statement :=
          ' select tb.template_id, ttl.name, tb.start_date_active, tb.end_date_active,'||
          ' tb.default_flag, tb.last_update_date, tb.attribute1,' ||
          ' tb.UNI_QUESTION_NOTE_FLAG, tb.UNI_QUESTION_NOTE_TYPE' ||
          ' from cs_tp_templates_b tb, cs_tp_templates_tl ttl ' ||
          ' where  tB.TEMPLATE_ID = ttl.TEMPLATE_ID' ||
          ' and    ttl.LANGUAGE = userenv(''LANG'') ' ||
          ' and exists ( '|| l_sel_template_stmt ||
          ' and a' || firstOne ||
          '.template_id=tb.template_id ) ' ||
          ' and trunc(sysdate) between trunc(nvl(tb.start_date_active, sysdate))' ||
          ' and trunc(nvl(tb.end_date_active, sysdate)) ';

   l_CursorID := dbms_sql.open_cursor;
   dbms_sql.parse(l_CursorID, l_Cursor_Statement, dbms_sql.NATIVE);

   For i In p_Object_Other_list.First..p_Object_Other_list.LAST Loop
      If ( needBind ( i) = 1 ) then
        If(p_Object_Other_list(i).mOBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
            dbms_sql.bind_variable (l_CursorID, ':v_Other_ID' || i ,
                                    p_Object_Other_list(i).mother_id);
          dbms_sql.bind_variable (l_CursorID, ':v_Object_Code' || i,
                                  p_Object_Other_list(i).mobject_code);
        Else
           If(p_Object_Other_list(i).mLOOKUP_CODE <> 'NONE') Then
            dbms_sql.bind_variable (l_CursorID, ':v_Other_CODE' || i ,
                                    p_Object_Other_list(i).mLOOKUP_CODE);
            dbms_sql.bind_variable (l_CursorID, ':v_Object_Code' || i,
                                    p_Object_Other_list(i).mobject_code);
           End If;
        End If;
      End If; -- end needBind IF
  End Loop;

    dbms_sql.define_column(l_CursorID, 1, L_TEMPLATE_ID);
    dbms_sql.define_column(l_CursorID, 2, L_TEMPLATE_NAME, 300);
    dbms_sql.define_column(l_CursorID, 3, L_START_DATE);
    dbms_sql.define_column(l_CursorID, 4, L_END_DATE);
    dbms_sql.define_column(l_CursorID, 5, L_DEFAULT_FLAG, 100);
    dbms_sql.define_column(l_CursorID, 6, L_LAST_UPDATE_DATE);
    dbms_sql.define_column(l_CursorID, 7, l_Short_Code, 150);
    dbms_sql.define_column(l_CursorID, 8, l_UNI_QUESTION_NOTE_FLAG, 1);
    dbms_sql.define_column(l_CursorID, 9, l_UNI_QUESTION_NOTE_TYPE, 30);

    l_total_attribute_num :=  dbms_sql.execute(l_CursorID);
    i:=0;
    While (dbms_sql.fetch_rows(l_CursorID) > 0) Loop

      dbms_sql.column_value(l_CursorID, 1, l_template_id);
      dbms_sql.column_value(l_CursorID, 2, l_template_name);
      dbms_sql.column_value(l_CursorID, 3, l_start_date);
      dbms_sql.column_value(l_CursorID, 4, l_end_date);
      dbms_sql.column_value(l_CursorID, 5, l_default_flag);
      dbms_sql.column_value(l_CursorID, 6, l_last_update_date);
      dbms_sql.column_value(l_CursorID, 7, l_short_code);
      dbms_sql.column_value(l_CursorID, 8, l_uni_question_note_flag);
      dbms_sql.column_value(l_CursorID, 9, l_uni_question_note_type);

      x_template_list(i).mTemplateID          := l_template_id;
      x_template_list(i).mTemplateName        := l_template_name;
      x_template_list(i).mUniQuestionNoteFlag := l_uni_question_note_flag;
      x_template_list(i).mUniQuestionNoteType := l_uni_question_note_type;
      x_template_list(i).mDefaultFlag         := l_default_flag;
      x_template_list(i).mShortCode           := l_short_code;
      x_template_list(i).mLast_Updated_Date
                := to_char (l_last_update_date, l_default_last_up_date_format);
      x_template_list(i).mStartDate
                := to_char (l_start_date, l_date_format);
      x_template_list(i).mEndDate
                := to_char(l_end_date, l_date_format);
      i:=i+1;
   End Loop;
   dbms_sql.close_cursor(l_CursorID);

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data
              );

  WHEN no_data_found THEN
  --x_return_status = FND_API.G_RET_STS_EXC_ERROR;
      FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data
              );

  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
           (p_count => x_msg_count ,
            p_data => x_msg_data
           );
      Raise;
END Show_Templates_With_Link;

PROCEDURE Show_Template_Attributes(
  p_api_version_number    IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR   := FND_API.G_FALSE,
  p_template_id           IN  NUMBER,
  p_jtf_object_code       IN  VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_template_attributes   OUT NOCOPY Template_Attribute_List )
IS
    l_api_name     CONSTANT       VARCHAR2(30)   := 'Show_Templates_Attributes';
    l_api_version  CONSTANT       NUMBER         := 1.0;
    l_SELECT_ID                   VARCHAR2(60);
    l_SELECT_NAME                 VARCHAR2(120);
    l_FROM_TABLE                  VARCHAR2(120);
    l_ORDER_BY_CLAUSE             VARCHAR2(120);
    l_where_clause                VARCHAR2(120);

    Cursor JTF_OBJ_C (v_jtf_obj_code VARCHAR2)  Is
      Select SELECT_ID,
             SELECT_NAME,
             FROM_TABLE,
             WHERE_CLAUSE,
             ORDER_BY_CLAUSE
      From   JTF_OBJECTS_VL
      Where  OBJECT_CODE = v_jtf_obj_code;

    l_statement                   VARCHAR2(1000);
    l_CursorID                    NUMBER;
    l_date_format                 VARCHAR2(60) := FND_API.G_MISS_CHAR;
    l_TEMPLATE_ATTRIBUTE_ID       NUMBER;
    l_ATTRIBUTE_NAME              VARCHAR2 (300);
    l_START_THRESHOLD             NUMBER;
    l_END_THRESHOLD               NUMBER;
    l_OTHER_ID                    NUMBER;
    l_LAST_UPDATE_DATE            DATE;
    l_total_attribute_num         NUMBER;
    l_defaultflag                 VARCHAR2(30);
    i                             NUMBER;

BEGIN
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- Start API Body
  l_date_format := get_date_format;
  Open JTF_OBJ_C (P_JTF_OBJECT_CODE);
  Fetch JTF_OBJ_C
  Into l_SELECT_ID, l_SELECT_NAME, l_FROM_TABLE, l_where_clause, l_ORDER_BY_CLAUSE;
  If (JTF_OBJ_C%notfound) Then
  Close JTF_OBJ_C;
       X_Return_Status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ATTR_JTFOB');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
  End If;
  Close JTF_OBJ_C;

  If (l_ORDER_BY_CLAUSE Is Null
      Or l_ORDER_BY_CLAUSE = FND_API.G_MISS_CHAR
      Or length(l_ORDER_BY_CLAUSE)<=0 ) Then

      l_statement := 'SELECT  INT.TEMPLATE_ATTRIBUTE_ID, JTFO.'
        || l_SELECT_NAME
        || ', INT.START_THRESHOLD, INT.END_THRESHOLD, JTFO.'
        || l_SELECT_ID
        || ', INT.LAST_UPDATE_DATE, INT.ATTRIBUTE1 FROM (SELECT * FROM CS_TP_TEMPLATE_ATTRIBUTE ATTR, '
        || l_FROM_TABLE
        || '  INNER  WHERE '
        || l_where_clause
        || ' and ATTR.OTHER_ID =INNER.'
        || l_SELECT_ID
        || ' AND ATTR.TEMPLATE_ID='
        || ':P_Template_ID'
        || ' AND ATTR.OBJECT_CODE ='
        || ':P_JTF_OBJECT_CODE'
        || ')  INT, '
        || l_FROM_TABLE
        || ' JTFO WHERE INT.OTHER_ID(+) = JTFO.'
        || l_SELECT_ID
        || ' AND '
        || l_where_clause;
   Else
     l_statement := 'SELECT  INT.TEMPLATE_ATTRIBUTE_ID, JTFO.'
      || l_SELECT_NAME
      || ', INT.START_THRESHOLD, INT.END_THRESHOLD, JTFO.'
      || l_SELECT_ID
      || ', INT.LAST_UPDATE_DATE,  INT.ATTRIBUTE1  FROM (SELECT ATTR.* FROM CS_TP_TEMPLATE_ATTRIBUTE ATTR, '
      || l_FROM_TABLE
      || '  INNER  WHERE '
      || l_where_clause
      || ' and ATTR.OTHER_ID =INNER.'
      || l_SELECT_ID
      || ' AND ATTR.TEMPLATE_ID='
      || ':P_Template_ID'
      || ' AND ATTR.OBJECT_CODE ='
      || ':P_JTF_OBJECT_CODE'
      || ')  INT, '
      || l_FROM_TABLE
      || ' JTFO WHERE INT.OTHER_ID(+) = JTFO.'
      || l_SELECT_ID
      || ' AND '
      || l_where_clause
      || ' ORDER BY JTFO.'
      || l_ORDER_BY_CLAUSE;
    End If;

    l_CursorID := dbms_sql.open_cursor;
    dbms_sql.parse(l_CursorID, l_statement, dbms_sql.NATIVE);

    dbms_sql.bind_variable(l_CursorID, 'P_Template_ID', P_Template_ID);
    dbms_sql.bind_variable(l_CursorID, 'P_JTF_OBJECT_CODE', P_JTF_OBJECT_CODE);

    dbms_sql.define_column(l_CursorID, 1, l_template_attribute_id);
    dbms_sql.define_column(l_CursorID, 2, l_attribute_name, 300);
    dbms_sql.define_column(l_CursorID, 3, l_start_threshold);
    dbms_sql.define_column(l_CursorID, 4, l_end_threshold);
    dbms_sql.define_column(l_CursorID, 5, l_other_id);
    dbms_sql.define_column(l_CursorID, 6, l_last_update_date);
    dbms_sql.define_column(l_CursorID, 7, l_defaultflag, 30);

    l_total_attribute_num :=  dbms_sql.execute(l_CursorID);

    i:=0;
    While (dbms_sql.fetch_rows(l_CursorID) > 0) Loop
        dbms_sql.column_value(l_CursorID, 1, l_template_attribute_id);
        dbms_sql.column_value(l_CursorID, 2, l_attribute_name);
        dbms_sql.column_value(l_CursorID, 3, l_start_threshold);
        dbms_sql.column_value(l_CursorID, 4, l_end_threshold);
        dbms_sql.column_value(l_CursorID, 5, l_other_id);
        dbms_sql.column_value(l_CursorID, 6, l_last_update_date);
        dbms_sql.column_value(l_CursorID, 7, l_defaultflag);
        x_template_attributes (i).mAttributeID     := l_template_attribute_id;
        x_template_attributes (i).mAttributeName   := l_attribute_name;
        x_template_attributes (i).mStartThreshold  := l_start_threshold;
        x_template_attributes (i).mEndThreshold    := l_end_threshold;
        x_template_attributes (i).mJTF_OBJECT_CODE := p_jtf_object_code ;
        x_template_attributes (i).mOther_ID        := l_other_id;
        x_template_attributes (i).mDefaultFlag     := l_defaultflag;
        x_template_attributes (i).mLast_Updated_Date
                 := to_char (l_last_update_date, l_default_last_up_date_format);

        i:= i+1;
    End Loop;
    dbms_sql.close_cursor(l_CursorID);

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data
              );
END   Show_Template_Attributes;

PROCEDURE Show_Template_Links(
    p_api_version_number IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit             IN  VARCHAR   := FND_API.G_FALSE,
    P_Template_ID        IN  NUMBER,
    P_JTF_OBJECT_CODE    IN  VARCHAR2,
    X_Msg_Count          OUT NOCOPY NUMBER,
    X_Msg_Data           OUT NOCOPY VARCHAR2,
    X_Return_Status      OUT NOCOPY VARCHAR2,
    X_Template_Links     OUT NOCOPY Template_Link_List)
IS
  l_api_name     CONSTANT       VARCHAR2(30)   := 'Show_Templates_Attributes';
  l_api_version  CONSTANT       NUMBER         := 1.0;
  l_SELECT_ID                   VARCHAR2(60);
  l_SELECT_NAME                 VARCHAR2(1000);
  l_SELECT_DETAIL               VARCHAR2(1000);
  l_FROM_TABLE                  VARCHAR2(1000);
  l_ORDER_BY_CLAUSE             VARCHAR2(1000);
  l_WHERE_CLAUSE                VARCHAR2(1000);

  Cursor JTF_OBJ_C (v_jtf_obj_code VARCHAR2) IS
    Select SELECT_ID,
           SELECT_NAME,
           SELECT_DETAILS,
           FROM_TABLE,
           WHERE_CLAUSE,
           ORDER_BY_CLAUSE
    From   JTF_OBJECTS_VL
    Where  OBJECT_CODE = v_jtf_obj_code;

  l_statement                   VARCHAR2(1000);
  l_CursorID                    NUMBER;
  l_date_format                 VARCHAR2(60) := FND_API.G_MISS_CHAR;
  l_LINK_ID                     NUMBER;
  l_LINK_NAME                   VARCHAR2(300);
  l_LINK_DESC                   VARCHAR2(1000);
  l_OTHER_ID                    NUMBER;
  l_OTHER_CODE                  VARCHAR2(30);
  l_LAST_UPDATE_DATE            DATE;
  l_total_attribute_num         NUMBER;
  i                             NUMBER;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

    -- Start API Body
    l_date_format := get_date_format;
    Open JTF_OBJ_C (P_JTF_OBJECT_CODE);
    Fetch JTF_OBJ_C
    Into l_SELECT_ID, l_SELECT_NAME, l_SELECT_DETAIL,  l_FROM_TABLE,
         l_WHERE_CLAUSE, l_ORDER_BY_CLAUSE;
    If (JTF_OBJ_C%notfound) Then
       Close JTF_OBJ_C;
       X_Return_Status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ATTR_JTFOB');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    End If;
    Close JTF_OBJ_C;

    If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
       If (l_ORDER_BY_CLAUSE Is Null
          Or l_ORDER_BY_CLAUSE = FND_API.G_MISS_CHAR
          Or length(l_ORDER_BY_CLAUSE)<= 0) Then

            l_statement := 'SELECT LINK.LINK_ID, '
                  || l_SELECT_NAME
                  || ', '
                  || l_SELECT_DETAIL
                  || ','
                  || l_SELECT_ID
                  || ', LINK.LAST_UPDATE_DATE FROM CS_TP_TEMPLATE_LINKS LINK, '
                  || l_FROM_TABLE
                  || ' WHERE '
                  || l_WHERE_CLAUSE
                  || ' AND LINK.OTHER_ID = '
                  || l_SELECT_ID
                  || ' AND LINK.TEMPLATE_ID =  '
                  || ' :P_Template_ID '
                  || ' AND LINK.OBJECT_CODE ='''
                  || P_JTF_OBJECT_CODE
                  || '''';
       Else
           l_statement := 'SELECT LINK.LINK_ID, '
                  || l_SELECT_NAME
                  || ', '
                  || l_SELECT_DETAIL
                  || ', '
                  || l_SELECT_ID
                  || ', LINK.LAST_UPDATE_DATE FROM CS_TP_TEMPLATE_LINKS LINK, '
                  || l_FROM_TABLE
                  || ' WHERE '
                  || l_WHERE_CLAUSE
                  || ' AND LINK.OTHER_ID = '
                  || l_SELECT_ID
                  || ' AND LINK.TEMPLATE_ID =  '
                  || ' :P_Template_ID '
                  || ' AND LINK.OBJECT_CODE ='''
                  || P_JTF_OBJECT_CODE
                  || '''  ORDER BY '
                  || l_ORDER_BY_CLAUSE;
       End If;
    Else -- this is for the problem code case
      If (l_ORDER_BY_CLAUSE Is Null
        Or l_ORDER_BY_CLAUSE = FND_API.G_MISS_CHAR
        Or length(l_ORDER_BY_CLAUSE)<=0 ) Then
         l_statement := 'SELECT LINK.LINK_ID, '
                 || l_SELECT_NAME
                 || ', '
                 || l_SELECT_DETAIL
                 || ','
                 || l_SELECT_ID
                 || ', LINK.LAST_UPDATE_DATE FROM CS_TP_TEMPLATE_LINKS LINK, '
                 || l_FROM_TABLE
                 || ' WHERE '
                 || l_WHERE_CLAUSE
                 || ' AND LINK.LOOKUP_CODE = '
                 || l_SELECT_ID
                 || ' AND LINK.TEMPLATE_ID =  '
                 || ' :P_Template_ID '
                 || ' AND LINK.OBJECT_CODE ='''
                 || P_JTF_OBJECT_CODE
                 || '''';
      Else
         l_statement := 'SELECT LINK.LINK_ID, '
                 || l_SELECT_NAME
                 || ', '
                 || l_SELECT_DETAIL
                 || ', '
                 || l_SELECT_ID
                 || ', LINK.LAST_UPDATE_DATE FROM CS_TP_TEMPLATE_LINKS LINK, '
                 || l_FROM_TABLE
                 || ' WHERE '
                 || l_WHERE_CLAUSE
                 || ' AND LINK.LOOKUP_CODE = '
                 || l_SELECT_ID
                 || ' AND LINK.TEMPLATE_ID =  '
                 || ' :P_Template_ID '
                 || ' AND LINK.OBJECT_CODE ='''
                 || P_JTF_OBJECT_CODE
                 || '''  ORDER BY '
                 || l_ORDER_BY_CLAUSE;
     End If;
    End If;

    l_CursorID := dbms_sql.open_cursor;
    dbms_sql.parse(l_CursorID, l_statement, dbms_sql.NATIVE);
    dbms_sql.define_column(l_CursorID, 1, L_LINK_ID);
    dbms_sql.define_column(l_CursorID, 2, L_LINK_NAME, 300);
    dbms_sql.define_column(l_CursorID, 3, L_LINK_DESC, 1000);

    If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
      dbms_sql.define_column(l_CursorID, 4, L_OTHER_ID);
    Else
      dbms_sql.define_column(l_CursorID, 4, L_OTHER_CODE, 30);
    End If;

    dbms_sql.define_column(l_CursorID, 5, L_LAST_UPDATE_DATE);

    dbms_sql.bind_variable(l_CursorID, 'P_Template_ID', P_Template_ID);
    l_total_attribute_num := dbms_sql.execute(l_CursorID);

    i:=0;
    While (dbms_sql.fetch_rows(l_CursorID) > 0) Loop
      dbms_sql.column_value(l_CursorID, 1, l_link_id);
      dbms_sql.column_value(l_CursorID, 2, l_link_name);
      dbms_sql.column_value(l_CursorID, 3, l_link_desc);

      If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
       dbms_sql.column_value(l_CursorID, 4, l_other_id);
      Else
       dbms_sql.column_value(l_CursorID, 4, l_other_code);
      End If;

      dbms_sql.column_value(l_CursorID, 5, l_last_update_date);
      x_template_links (i).mLinkID          := l_link_id;
      x_template_links (i).mLinkName        :=  l_link_name;
      x_template_links (i).mLinkDesc        := l_link_desc;
      x_template_links (i).mJTF_OBJECT_CODE := p_jtf_object_code;

      If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
       x_template_links (i).mOther_ID  := l_other_id;
      Else
       x_template_links (i).LOOKUP_CODE := l_other_code;
      End If;
      x_template_links (i).mLAST_UPDATED_DATE :=
          to_char (l_last_update_date, l_default_last_up_date_format);

      i:= i+1;
    End Loop;
    dbms_sql.close_cursor(l_CursorID);

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
                 p_data => x_msg_data);
END  Show_Template_Links;

PROCEDURE Show_Non_Asso_Links(
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN  VARCHAR   := FND_API.G_FALSE,
    p_template_id         IN  NUMBER,
    p_jtf_object_code     IN  VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_template_link_list  OUT NOCOPY Template_Link_List)
IS
    l_api_name     CONSTANT       VARCHAR2(30)   := 'Show_Non_Asso_Links';
    l_api_version  CONSTANT       NUMBER         := 1.0;
    l_select_id                   VARCHAR2(60);
    l_select_name                 VARCHAR2(1000);
    l_select_detail               VARCHAR2(1000);
    l_from_table                  VARCHAR2(1000);
    l_order_by_clause             VARCHAR2(1000);
    l_where_clause                VARCHAR2(1000);

    Cursor JTF_OBJ_C (v_jtf_obj_code VARCHAR2)  Is
      Select SELECT_ID,
             SELECT_NAME,
             SELECT_DETAILS,
             FROM_TABLE,
             WHERE_CLAUSE,
             ORDER_BY_CLAUSE
      From JTF_OBJECTS_VL
      Where OBJECT_CODE = v_jtf_obj_code;

    l_statement                   VARCHAR2(1000);
    l_CursorID                    NUMBER;
    l_date_format                 VARCHAR2(60)  := FND_API.G_MISS_CHAR;
    l_LINK_NAME                   VARCHAR2(300);
    l_LINK_DETAIL                 VARCHAR2(1000);
    l_OTHER_ID                    NUMBER;
    l_OTHER_CODE                  VARCHAR2(30);
    l_LAST_UPDATE_DATE            DATE;
    l_total_attribute_num         NUMBER;
    i                             NUMBER;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

    -- Start API Body
    l_date_format := get_date_format;
    Open JTF_OBJ_C (P_JTF_OBJECT_CODE);
    Fetch JTF_OBJ_C
    Into l_SELECT_ID, l_SELECT_NAME,l_SELECT_DETAIL,
         l_FROM_TABLE,l_WHERE_CLAUSE, l_ORDER_BY_CLAUSE;
    If (JTF_OBJ_C%notfound) Then
         Close JTF_OBJ_C;
         X_Return_Status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ATTR_JTFOB');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
    End If;
    Close JTF_OBJ_C;

    If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
       If (l_ORDER_BY_CLAUSE Is Null
        Or l_ORDER_BY_CLAUSE= FND_API.G_MISS_CHAR
        Or length(l_ORDER_BY_CLAUSE) <=0 ) Then
             l_statement := 'SELECT '
                       || l_SELECT_ID
                       || ', '
                       || l_SELECT_NAME
                       ||  ', '
                       || l_SELECT_DETAIL
                       ||  ' FROM '
                       || l_FROM_TABLE
                       || ' WHERE '
                       || l_WHERE_CLAUSE
                       || ' AND '
                       || ' NOT EXISTS (SELECT '
                       || '''x'''
                       || ' FROM CS_TP_TEMPLATE_LINKS LINK WHERE  LINK.TEMPLATE_ID =  '
                       || ' :P_Template_ID '
                       || ' AND LINK.OBJECT_CODE ='''
                       || P_JTF_OBJECT_CODE
                       || ''' AND LINK.OTHER_ID = '
                       || l_SELECT_ID
                       || ' ) ';
       Else
            l_statement := 'SELECT '
                       || l_SELECT_ID
                       || ', '
                       || l_SELECT_NAME
                       ||  ', '
                       || l_SELECT_DETAIL
                       || ' FROM '
                       || l_FROM_TABLE
                       || ' WHERE '
                       || l_WHERE_CLAUSE
                       || ' AND '
                       || ' NOT EXISTS (SELECT '
                       || '''x'''
                       || ' FROM CS_TP_TEMPLATE_LINKS LINK WHERE  LINK.TEMPLATE_ID =  '
                       || ' :P_Template_ID '
                       || ' AND LINK.OBJECT_CODE ='''
                       || P_JTF_OBJECT_CODE
                       || ''' AND LINK.OTHER_ID = '
                       || l_SELECT_ID
                       || ' )  ORDER BY '
                       || l_ORDER_BY_CLAUSE;
       End If;
     Else
       If (l_ORDER_BY_CLAUSE Is Null
          Or l_ORDER_BY_CLAUSE = FND_API.G_MISS_CHAR
          Or length(l_ORDER_BY_CLAUSE) <=0 ) Then
           l_statement := 'SELECT '
                      || l_SELECT_ID
                      || ', '
                      || l_SELECT_NAME
                      ||  ', '
                      || l_SELECT_DETAIL
                      ||  ' FROM '
                      || l_FROM_TABLE
                      || ' WHERE '
                      || l_WHERE_CLAUSE
                      || ' AND '
                      || l_SELECT_ID
                      || ' NOT IN (SELECT LOOUP_CODE FROM CS_TP_TEMPLATE_LINKS LINK WHERE  LINK.TEMPLATE_ID =  '
                      || ' :P_Template_ID '
                      || ' AND LINK.OBJECT_CODE ='''
                      || P_JTF_OBJECT_CODE
                      || ''' ) ';
        Else
            l_statement := 'SELECT '
                      || l_SELECT_ID
                      || ', '
                      || l_SELECT_NAME
                      ||  ', '
                      || l_SELECT_DETAIL
                      || ' FROM '
                      || l_FROM_TABLE
                      || ' WHERE '
                      || l_WHERE_CLAUSE
                      || ' AND '
                      || l_SELECT_ID
                      || ' NOT IN (SELECT LOOKUP_CODE FROM CS_TP_TEMPLATE_LINKS LINK WHERE  LINK.TEMPLATE_ID =  '
                      || ' :P_Template_ID '
                      || ' AND LINK.OBJECT_CODE ='''
                      || P_JTF_OBJECT_CODE
                      || ''' )  ORDER BY '
                      || l_ORDER_BY_CLAUSE;
         End If;
    End If;

    l_CursorID := dbms_sql.open_cursor;
    dbms_sql.parse(l_CursorID, l_statement, dbms_sql.NATIVE);

    If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
      dbms_sql.define_column(l_CursorID, 1, l_other_id);
    Else
      dbms_sql.define_column(l_CursorID, 1, l_other_code, 30);
    End If;
    dbms_sql.define_column(l_CursorID, 2, l_link_name, 300);
    dbms_sql.define_column(l_CursorID, 3, l_link_detail, 1000);

    dbms_sql.bind_variable(l_CursorID, 'P_Template_ID', P_Template_ID);
    l_total_attribute_num := dbms_sql.execute(l_CursorID);
    i:=0;
    While (dbms_sql.fetch_rows(l_CursorID) > 0) Loop
        If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
          dbms_sql.column_value(l_CursorID, 1, l_other_id);
        Else
          dbms_sql.column_value(l_CursorID, 1, l_other_code);
        End If;
        dbms_sql.column_value(l_CursorID, 2, l_link_name);
        dbms_sql.column_value(l_CursorID, 3, l_link_detail);
        If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
          x_template_link_list (i).mOther_ID := l_other_id;
        Else
          x_template_link_list (i).LOOKUP_CODE := l_other_code;
        End If;
        x_template_link_list (i).mLinkName :=  l_link_name;
        x_template_link_list (i).mLinkDesc := l_link_detail;

        i:= i+1;
    End Loop;

    dbms_sql.close_cursor(l_CursorID);

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
                 p_data => x_msg_data
                );
END Show_Non_Asso_Links;

PROCEDURE Show_Link_Attribute_List (
    p_api_version_number IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2  := FND_API.G_FALSE,
    P_Identify           IN  VARCHAR2,
    X_Msg_Count          OUT NOCOPY NUMBER,
    X_Msg_Data           OUT NOCOPY VARCHAR2,
    X_Return_Status      OUT NOCOPY VARCHAR2,
    X_IDName_Pairs       OUT NOCOPY ID_NAME_PAIRS)
IS
    l_api_name       CONSTANT VARCHAR2(30) := 'Show_Link_Attribute_List';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_application_id CONSTANT NUMBER       :=672;
    l_object_code             VARCHAR2 (100);
    l_name                    VARCHAR2 (200);
    i                         NUMBER;

    Cursor JTF_OBJECT_CURSOR (v_app_id NUMBER, v_object_function VARCHAR2)Is
      Select OBJECT_CODE,
             NAME
      From JTF_OBJECTS_VL
      Where APPLICATION_ID = v_app_id
      And OBJECT_FUNCTION like v_object_function;

BEGIN
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- Start API Body
  If (P_Identify like g_jtf_link) Then
        Open JTF_OBJECT_CURSOR (l_application_id, g_jtf_link);
  Elsif (P_Identify Like g_jtf_attribute) Then
        Open JTF_OBJECT_CURSOR (l_application_id, g_jtf_attribute);
  Else
    x_return_status := FND_API.G_RET_STS_ERROR;
    If (JTF_OBJECT_CURSOR%ISOPEN) Then
        Close JTF_OBJECT_CURSOR;
    End If;
    FND_MESSAGE.SET_NAME('CS','CS_TP_Link_Iden_INVALID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  End If;

  i:=0;
  Loop
      Fetch  JTF_OBJECT_CURSOR Into l_OBJECT_CODE, l_NAME;
      Exit When (JTF_OBJECT_CURSOR%NOTFOUND);
      X_IDName_Pairs(i).mOBJECT_CODE := l_OBJECT_CODE;
      -- added by weim
      if(instr(l_NAME, ' ') = 1) then
        l_NAME := substr(l_NAME,2);
      end if;

      X_IDName_Pairs(i).mNAME        := l_NAME;
      i:=i+1;
  End Loop;
  Close JTF_OBJECT_CURSOR;

  If (i<0) Then
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('CS','CS_TP_Link_Unseeded');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  End If;

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data
              );

  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
           (p_count => x_msg_count ,
            p_data => x_msg_data
           );
      Raise;
END  Show_Link_Attribute_List;

PROCEDURE Retrieve_Constants (
  p_api_version_number IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2  := FND_API.G_FALSE,
  X_Msg_Count          OUT NOCOPY NUMBER,
  X_Msg_Data           OUT NOCOPY VARCHAR2,
  X_Return_Status      OUT NOCOPY VARCHAR2,
  X_IDName_Pairs       OUT NOCOPY ID_NAME_PAIRS)
IS

BEGIN
  null;
END;

PROCEDURE Show_Default_Template  (
    p_api_version_number IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2  := FND_API.G_FALSE,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_default_template   OUT NOCOPY Template)
IS
    l_api_name                    VARCHAR2(30) := 'Show_Default_Template';
    l_api_version  CONSTANT       NUMBER       := 1.0;
    l_date_format                 VARCHAR2(60) := FND_API.G_MISS_CHAR;
    l_g_true      CONSTANT        VARCHAR2(1)  := FND_API.G_TRUE;
    l_statement                   VARCHAR2(1000);
    L_TEMPLATE_ID                 NUMBER;
    L_TEMPLATE_NAME               VARCHAR2(500);
    L_START_DATE_ACTIVE           DATE;
    L_END_DATE_ACTIVE             DATE;
    L_LAST_UPDATED_DATE           DATE;
    L_DEFAULT_FLAG                VARCHAR2(60);
    l_Short_Code                  VARCHAR2(150);
    l_CursorID                    NUMBER;
    L_Total                       NUMBER;

  Cursor l_tp_template_csr (dFlag VARCHAR2) IS
    Select T.TEMPLATE_ID,
           T.NAME,
           T.START_DATE_ACTIVE,
           T.END_DATE_ACTIVE,
           T.DEFAULT_FLAG,
           T.LAST_UPDATE_DATE,
           T.ATTRIBUTE1,
           T.UNI_QUESTION_NOTE_FLAG,
           T.UNI_QUESTION_NOTE_TYPE
    From  CS_TP_TEMPLATES_VL T
    Where T.DEFAULT_FLAG = dFlag;
  l_tp_template_rec l_tp_template_csr%ROWTYPE;
BEGIN
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- Start API Body
  -- l_date_format := get_date_format;
  l_date_format := get_date_format_from_user_two;
  l_default_update_format2 :=
    get_date_format_from_user_two||' HH24:MI:SS';

  Open l_tp_template_csr ( l_g_true );
  Loop
    Fetch l_tp_template_csr Into l_tp_template_rec;
    Exit When l_tp_template_csr%NOTFOUND;

      x_default_template.mTemplateID   := l_tp_template_rec.template_id;
      x_default_template.mTemplateName := l_tp_template_rec.name;
      x_default_template.mStartDate
              := to_char (l_tp_template_rec.start_date_active, l_date_format);
      x_default_template.mEndDate
              := to_char( l_tp_template_rec.end_date_active, l_date_format);
      x_default_template.mDefaultFlag  := l_tp_template_rec.DEFAULT_FLAG;
      x_default_template.mLast_Updated_Date
              := to_char( l_tp_template_rec.last_update_date, l_default_update_format2);
      x_default_template.mShortCode := l_tp_template_rec.attribute1;
      x_default_template.mUniQuestionNoteFlag
              := l_tp_template_rec.uni_question_note_flag;
      x_default_template.mUniQuestionNoteType
              := l_tp_template_rec.uni_question_note_type;

  End Loop;
  Close l_tp_template_csr;

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);
END Show_Default_Template;

PROCEDURE Show_Error_Message (
  p_api_version_number   IN   NUMBER,
  X_Out_Message          OUT NOCOPY  VARCHAR2)
IS
  One_Message    VARCHAR2(1000);
  i              NUMBER;
BEGIN
  i := 1;
  While (i <= FND_MSG_PUB.Count_Msg) Loop
     One_Message := FND_MSG_PUB.Get (p_msg_index => i,
                                     p_encoded   => FND_API.G_FALSE);
     X_Out_Message := X_Out_Message || One_Message;
     i := i+1;
  End Loop;

END Show_Error_Message;


PROCEDURE Copy_Template(
   p_api_version_number IN NUMBER,
   b_template_id        IN NUMBER,
   x_template_name      IN VARCHAR2,
   p_init_msg_list      IN VARCHAR2    := FND_API.G_FALSE,
   p_commit             IN VARCHAR     := FND_API.G_FALSE,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_template_id        OUT NOCOPY NUMBER)

IS

   l_api_name     CONSTANT VARCHAR2(20)   :=  'Copy_Template';
   g_pkg_pkg_name CONSTANT VARCHAR2(20)   := 'Copy_PVT';
   l_api_version  CONSTANT NUMBER         :=  1.0;
   l_init_msg_list_true   VARCHAR2(20)    := FND_API.G_TRUE;
   l_init_msg_list_false  VARCHAR2(20)    := FND_API.G_FALSE;
   l_init_commit_true     VARCHAR2(20)    := FND_API.G_FALSE; --//false
   l_init_commit_false    VARCHAR2(20)    := FND_API.G_FALSE;
   l_template_general_info    CS_TP_TEMPLATES_PVT.Template ;
   l_template_attr_namepairs  CS_TP_TEMPLATES_PVT.ID_NAME_PAIRS;
   l_template_attr_namepair   CS_TP_TEMPLATES_PVT.ID_NAME_PAIR;
   l_temp_counter             NUMBER      := 0;
   l_template_link_list       CS_TP_TEMPLATES_PVT.Template_Link_List;
   l_medium_templink_list     CS_TP_TEMPLATES_PVT.Template_Link_List;
   l_template_attribute_list  CS_TP_TEMPLATES_PVT.Template_Attribute_list;
   l_template_attribute       CS_TP_TEMPLATES_PVT.Template_Attribute;
   l_template_question_list   CS_TP_QUESTIONS_PVT.Question_List;
   l_template_question_number NUMBER;
   l_templ_ques_retriv_num    NUMBER;
   l_template_question        CS_TP_QUESTIONS_PVT.Question;
   i                          NUMBER;
   initial_value              NUMBER := 1;
   l_template_question_ID     NUMBER;
   l_template_question_choice     CS_TP_CHOICES_PVT.Choice;
   l_templ_quest_choice_list      CS_TP_CHOICES_PVT.Choice_List;
   l_template_question_freetext   CS_TP_CHOICES_PVT.FREETEXT;
   l_templ_quest_lookup_ID        NUMBER;
   l_template_question_choice_ID  NUMBER;
   l_template_question_text_ID    NUMBER;

begin
    X_Template_ID := 0;

--/** a)Query the general information by the old given template ID
      CS_TP_TEMPLATES_PVT.Show_Template(
                    p_api_version_number => p_api_version_number,
                    p_init_msg_list      => l_init_msg_list_true,
                    p_commit             => l_init_commit_true,
                    P_Template_ID        => B_Template_ID,
                    X_Msg_Count          => X_Msg_Count,
                    X_Msg_Data           => X_Msg_Data,
                    X_Return_Status      => X_Return_Status,
                    X_Template_To_Show   => l_template_general_info);


--/** b) Generate one new template ID by these general information
     l_template_general_info.mTemplateName := X_Template_Name;
     l_template_general_info.mDefaultFlag  := FND_API.G_FALSE;

     CS_TP_TEMPLATES_PVT.Add_Template(p_api_version_number  => p_api_version_number,
                  p_init_msg_list       => l_init_msg_list_true,
                  p_commit              => l_init_commit_true,
                  P_One_Template        => l_template_general_info,
                  X_Msg_Count           => X_Msg_Count,
                  X_Msg_Data            => X_Msg_Data,
                  X_Return_Status       => X_Return_Status,
                  X_Template_ID         => X_Template_ID);

--/** c) Query the template link information
--/** c1) First need to query all the attributes lists codes
      CS_TP_TEMPLATES_PVT.Show_Link_Attribute_List (
              p_api_version_number => p_api_version_number,
              p_init_msg_list      => l_init_msg_list_true,
              p_commit             => l_init_commit_true,
              P_Identify       => CS_TP_TEMPLATES_PVT.G_JTF_LINK,
              X_Msg_Count       => X_Msg_Count,
                X_Msg_Data       => X_Msg_Data,
               X_Return_Status     => X_Return_Status,
              X_IDName_Pairs     => l_template_attr_namepairs);

--/** c2) For each given attribute list code, we need to update and the new
--/**      generated template..
      While(l_template_attr_namepairs.EXISTS(l_temp_counter)) Loop
          l_template_attr_namepair.mOBJECT_CODE :=
              l_template_attr_namepairs(l_temp_counter).mOBJECT_CODE;
          l_template_attr_namepair.mNAME        :=
              l_template_attr_namepairs(l_temp_counter).mNAME;
     --/** query the attr links
         CS_TP_TEMPLATES_PVT.Show_Template_Links(
            p_api_version_number     => p_api_version_number,
            p_init_msg_list          => l_init_msg_list_true,
            p_commit                 => l_init_commit_true,
            P_Template_ID             => B_Template_ID,
            P_JTF_OBJECT_CODE         => l_template_attr_namepair.mOBJECT_CODE,
            X_Msg_Count               => X_Msg_Count,
            X_Msg_Data               => X_Msg_Data,
             X_Return_Status           => X_Return_Status,
            X_Template_Links         => l_template_link_list);

         If(l_template_link_list.exists(0)) Then
           For i IN  l_template_link_list.FIRST..l_template_link_list.LAST Loop
             l_template_link_list(i).mLinkID := NULL;
           End Loop;
         End If;
          --dbms_output.put_line(' I am here four' );

         CS_TP_TEMPLATES_PVT.Update_Template_Links (
              p_api_version_number  => p_api_version_number,
              p_init_msg_list       => l_init_msg_list_true,
              p_commit              => l_init_commit_true  ,
              P_Template_ID          => X_Template_ID,
              P_JTF_OBJECT_CODE      => l_template_attr_namepair.mOBJECT_CODE,
              P_Template_Links      => l_template_link_list,
              X_Msg_Count            => X_Msg_Count,
              X_Msg_Data            => X_Msg_Data,
              X_Return_Status       => X_Return_Status );

        l_temp_counter := l_temp_counter + 1;
      End Loop;

      l_temp_counter := 0; --// refresh this counter


--/** e) Query the template threshvalue information
--/** e1) Query the attribute lists
       CS_TP_TEMPLATES_PVT.Show_Link_Attribute_List (
          p_api_version_number => p_api_version_number,
          p_init_msg_list      => l_init_msg_list_true,
          p_commit             => l_init_commit_true,
          P_Identify           => CS_TP_TEMPLATES_PVT.G_JTF_ATTRIBUTE,
          X_Msg_Count           => X_Msg_Count,
          X_Msg_Data           => X_Msg_Data,
          X_Return_Status       => X_Return_Status,
          X_IDName_Pairs       => l_template_attr_namepairs);


--/** e2) For each attrlist, we need to query the old values and update the new
--/**     template.
     While(l_template_attr_namepairs.EXISTS(l_temp_counter)) Loop
        l_template_attr_namepair.mOBJECT_CODE :=
           l_template_attr_namepairs(l_temp_counter).mOBJECT_CODE;
        l_template_attr_namepair.mNAME        :=
           l_template_attr_namepairs(l_temp_counter).mNAME;

      --/** first query the old template value
        CS_TP_TEMPLATES_PVT.Show_Template_Attributes(
            p_api_version_number     => p_api_version_number,
            p_init_msg_list          => l_init_msg_list_true,
            p_commit                 => l_init_commit_true,
            P_Template_ID            => B_Template_ID,
            P_JTF_OBJECT_CODE        => l_template_attr_namepair.mOBJECT_CODE,
            X_Msg_Count               => X_Msg_Count,
            X_Msg_Data               => X_Msg_Data,
            X_Return_Status           => X_Return_Status,
            X_Template_Attributes     => l_template_attribute_list);

      --dbms_output.put_line(' I am done here five');
      If(l_template_attribute_list.exists(0)) Then
       For i IN l_template_attribute_list.FIRST..l_template_attribute_list.LAST Loop
           l_template_attribute_list(i).mAttributeID := NULL;
       End Loop;
      End If;
      --/** update the new template value
       CS_TP_TEMPLATES_PVT.Update_Template_Attributes  (
            p_api_version_number     => p_api_version_number,
            p_init_msg_list          => l_init_msg_list_true,
            p_commit                 => l_init_commit_true,
            P_Template_ID            => X_Template_ID,
            P_Template_Attributes    => l_template_attribute_list,
            X_Msg_Count               => X_Msg_Count,
             X_Msg_Data               => X_Msg_Data,
             X_Return_Status           => X_Return_Status);

       l_temp_counter := l_temp_counter + 1;
     End Loop;
     l_temp_counter := 0; --//** refresh this value

--/** g) Query the Quesions informaion by using the base template ID
    CS_TP_QUESTIONS_PVT.Show_Questions  (
          p_api_version_number     => p_api_version_number,
          p_init_msg_list          => l_init_msg_list_true,
          p_commit                 => l_init_commit_true,
          P_Template_ID            => B_Template_ID,
          P_Start_Question         => NULL,
          P_End_Question           => NULL,
          P_Display_Order          => NULL,
          X_Msg_Count              => X_Msg_Count,
          X_Msg_Data               => X_Msg_Data,
          X_Return_Status          => X_Return_Status,
          X_Question_List_To_Show  => l_template_question_list,
          X_Total_Questions        => l_template_question_number,
          X_Retrieved_Question_Number => l_templ_ques_retriv_num);


--/** I) next is to add these questions to the new template
    If(l_template_question_list.exists(0)) Then
      For i IN l_template_question_list.FIRST..l_template_question_list.LAST Loop
         l_template_question.mQuestionName
              := l_template_question_list(i).mQuestionName;
         l_template_question.mAnswerType
              := l_template_question_list(i).mAnswerType;
         l_template_question.mMandatoryFlag
              := l_template_question_list(i).mMandatoryFlag;
         l_template_question.mScoringFlag
              := l_template_question_list(i).mScoringFlag;
         l_template_question.mLookUpID
              := l_template_question_list(i).mLookUpID;
         l_template_question.mNoteType
              := l_template_question_list(i).mNoteType;
         l_template_question.mShowOnCreationFlag
              := l_template_question_list(i).mShowOnCreationFlag;


       CS_TP_QUESTIONS_PVT.Add_Question(
          p_api_version_number     => p_api_version_number,
          p_init_msg_list          => l_init_msg_list_true,
          p_commit                 => l_init_commit_true,
          P_One_Question           => l_template_question,
          p_Template_ID             => X_Template_ID,
          X_Msg_Count               => X_Msg_Count,
          X_Msg_Data               => X_Msg_Data,
          X_Return_Status           => X_Return_Status,
          X_Question_ID             => l_template_question_ID);

      Select Q.LOOKUP_ID
      Into l_templ_quest_lookup_ID
      From CS_TP_QUESTIONS_VL Q,
           CS_TP_LOOKUPS L,
           CS_TP_TEMPLATE_QUESTIONS TQ
      Where Q.LOOKUP_ID = L.LOOKUP_ID
      and TQ.QUESTION_ID = Q.QUESTION_ID
      and TQ.TEMPLATE_ID=X_Template_ID
      and Q.QUESTION_ID = l_template_question_ID;


     --//Next is to update the is new question conente according to the old
     --//Question content
    If(l_template_question_list(i).mAnswerType = 'CHOICE') Then
        CS_TP_CHOICES_PVT.Show_Choices (
           p_api_version_number   => p_api_version_number,
           p_init_msg_list        => l_init_msg_list_true,
           p_commit               => l_init_commit_true,
           P_Lookup_Id            => l_template_question_list(i).mLookUpID,
           P_Display_Order        => NULL,
           X_Msg_Count            => X_Msg_Count,
           X_Msg_Data              => X_Msg_Data,
           X_Return_Status        => X_Return_Status,
           X_Choice_List_To_Show  => l_templ_quest_choice_list);

     --//next is to add the choices
       While(l_templ_quest_choice_list.EXISTS(l_temp_counter)) Loop
        --//**l_template_question_choice.mChoiceID := l_template_question_choice_list(l_temp_counter).mChoiceID,
        l_template_question_choice.mChoiceName :=
             l_templ_quest_choice_list(l_temp_counter).mChoiceName;
        l_template_question_choice.mLookupID := l_templ_quest_lookup_ID;
        l_template_question_choice.mScore :=
            l_templ_quest_choice_list(l_temp_counter).mScore;

         CS_TP_CHOICES_PVT.Add_Choice (
           p_api_version_number    => p_api_version_number,
           p_init_msg_list         => l_init_msg_list_true,
           p_commit                => l_init_commit_true,
           p_One_Choice            => l_template_question_choice,
           X_Msg_Count             => X_Msg_Count,
           X_Msg_Data               => X_Msg_Data,
           X_Return_Status         => X_Return_Status,
           X_Choice_ID             => l_template_question_choice_ID);

         l_temp_counter := l_temp_counter + 1;
       End Loop;
       l_temp_counter := 0;
     End If;
     If(l_template_question_list(i).mAnswerType = 'FREETEXT') Then

       CS_TP_CHOICES_PVT.Show_Freetext (
          p_api_version_number   => p_api_version_number,
          p_init_msg_list        => l_init_msg_list_true,
          p_commit               => l_init_commit_true,
          P_Lookup_ID            => l_template_question_list(i).mLookUpID,
          X_Msg_Count             => X_Msg_Count,
          X_Msg_Data             => X_Msg_Data,
          X_Return_Status         => X_Return_Status,
          X_Freetext             => l_template_question_freetext);

      l_template_question_freetext.mLookUpID := l_templ_quest_lookup_ID;

      CS_TP_CHOICES_PVT.Add_Freetext (
         p_api_version_number    => p_api_version_number,
         p_init_msg_list         => l_init_msg_list_true,
         p_commit                => l_init_commit_true,
         P_One_Freetext           => l_template_question_freetext,
         X_Msg_Count             => X_Msg_Count,
         X_Msg_Data               => X_Msg_Data,
         X_Return_Status         => X_Return_Status,
         X_Freetext_ID           => l_template_question_text_ID );
     End If;

   End Loop;
   End If;
COMMIT WORK;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg(g_pkg_pkg_name ,l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
             (p_count => X_Msg_Count ,
              p_data => X_Msg_Data
             );
        ROLLBACK WORK ; --//rollback all the work
        Raise;
END Copy_Template;


PROCEDURE Test_Template_Obsolete(
   p_api_version_number IN NUMBER,
   B_Template_ID        IN NUMBER,
   p_init_msg_list      IN VARCHAR2    := FND_API.G_FALSE,
   p_commit             IN VARCHAR     := FND_API.G_FALSE,
   X_Msg_Count          OUT NOCOPY NUMBER,
   X_Msg_Data           OUT NOCOPY VARCHAR2,
   X_Return_Status      OUT NOCOPY VARCHAR2,
   B_Obsolete           OUT NOCOPY VARCHAR2)

IS
    l_api_name     CONSTANT VARCHAR2(30) := 'test_template_obsolete';
    g_pkg_pkg_name CONSTANT VARCHAR2(30) := 'CS_TP_TEMPLATES_PVT';
    l_current_date          DATE := sysdate;
    l_temp_date_format      VARCHAR2(100); --//*:= get_calender_date_format;
    l_date_format           VARCHAR2(100):= get_calender_date_format; --//** temp use
    l_template_general_info CS_TP_TEMPLATES_PVT.Template ;
BEGIN
    l_temp_date_format := get_calender_date_format;
    CS_TP_TEMPLATES_PVT.Show_Template(
        p_api_version_number => p_api_version_number,
        p_init_msg_list      => p_init_msg_list,
        p_commit             => p_commit,
        P_Template_ID        => B_Template_ID,
        X_Msg_Count          => X_Msg_Count,
        X_Msg_Data           => X_Msg_Data,
        X_Return_Status      => X_Return_Status,
        X_Template_To_Show   => l_template_general_info);

     B_Obsolete := FND_API.G_FALSE ; --//** set default to be valide

     l_date_format := get_date_format_from_user_two;
     If(l_template_general_info.mEndDate Is Not Null And
        (TO_DATE (l_template_general_info.mEndDate, l_date_format)) <
         l_current_date) Then
      --  (TO_DATE (l_current_date, l_date_format))) then
        B_Obsolete := FND_API.G_TRUE; --//** this template is obsolete;
     End If;

     If (l_template_general_info.mStartDate Is Not Null And
         (TO_DATE (l_template_general_info.mStartDate, l_date_format)) >
          l_current_date) Then
        B_Obsolete := FND_API.G_TRUE;
     End If;

EXCEPTION
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(g_pkg_pkg_name ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
           (p_count => X_Msg_Count ,
            p_data => X_Msg_Data
           );
      Raise;
END Test_Template_Obsolete;


procedure Show_Template_Links_Two
	(
	p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
        P_Template_ID			IN NUMBER,
	P_JTF_OBJECT_CODE		IN VARCHAR2,
        p_start_link                    IN NUMBER,
        p_end_link                      IN NUMBER,
	X_Msg_Count                     OUT NOCOPY NUMBER,
  	X_Msg_Data			OUT NOCOPY VARCHAR2,
 	X_Return_Status		        OUT NOCOPY VARCHAR2,
	X_Template_Links		OUT NOCOPY Template_Link_List,
        X_Total_Link_Number             OUT NOCOPY NUMBER,
        X_Retrieved_Link_Number         OUT NOCOPY NUMBER )
IS
  l_api_name     CONSTANT       VARCHAR2(30)   := 'Show_Templates_Links_Two';
  l_api_version  CONSTANT       NUMBER         := 1.0;
  l_SELECT_ID                   VARCHAR2(60);
  l_SELECT_NAME                 VARCHAR2(1000);
  l_SELECT_DETAIL               VARCHAR2(1000);
  l_FROM_TABLE                  VARCHAR2(1000);
  l_ORDER_BY_CLAUSE             VARCHAR2(1000);
  l_WHERE_CLAUSE                VARCHAR2(1000);

  Cursor JTF_OBJ_C (v_jtf_obj_code VARCHAR2) IS
    Select SELECT_ID,
           SELECT_NAME,
           SELECT_DETAILS,
           FROM_TABLE,
           WHERE_CLAUSE,
           ORDER_BY_CLAUSE
    From   JTF_OBJECTS_VL
    Where  OBJECT_CODE = v_jtf_obj_code;

  l_statement                   VARCHAR2(1000);
  l_CursorID                    NUMBER;
  l_date_format                 VARCHAR2(60) := FND_API.G_MISS_CHAR;
  l_LINK_ID                     NUMBER;
  l_LINK_NAME                   VARCHAR2(300);
  l_LINK_DESC                   VARCHAR2(1000);
  l_OTHER_ID                    NUMBER;
  l_OTHER_CODE                  VARCHAR2(30);
  l_LAST_UPDATE_DATE            DATE;
  l_total_attribute_num         NUMBER;
  i                             NUMBER;
  j                             NUMBER;
  l_start_link                  NUMBER;
  l_end_link                    NUMBER;

BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    X_Return_Status := FND_API.G_RET_STS_SUCCESS;


    l_start_link := p_start_link;
    l_end_link   := P_end_link;

    -- Check for null L_Start_Link and P_End_Link
    If (l_start_link Is Null
      Or l_start_link = FND_API.G_MISS_NUM) Then
       l_start_link := 1;
    End If;

    -- If L_End_LINK is NULL, set it to G_MISS_NUM
    -- which should be a greater than any template number
    If (l_end_link Is Null
      Or l_end_link = FND_API.G_MISS_NUM) then
       l_end_link := FND_API.G_MISS_NUM;
    End If;

    -- validation
    If (l_start_link > l_end_link
      Or l_start_link <= 0 Or l_end_link <= 0) Then
       X_Return_Status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_LINK_INQUIRY_INVALID');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    End If;

    -- Start API Body
    l_date_format := get_date_format;
    Open JTF_OBJ_C (P_JTF_OBJECT_CODE);
    Fetch JTF_OBJ_C
    Into l_SELECT_ID, l_SELECT_NAME, l_SELECT_DETAIL,  l_FROM_TABLE,
         l_WHERE_CLAUSE, l_ORDER_BY_CLAUSE;
    If (JTF_OBJ_C%notfound) Then
       Close JTF_OBJ_C;
       X_Return_Status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ATTR_JTFOB');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    End If;
    Close JTF_OBJ_C;

    If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
       If (l_ORDER_BY_CLAUSE Is Null
          Or l_ORDER_BY_CLAUSE = FND_API.G_MISS_CHAR
          Or length(l_ORDER_BY_CLAUSE)<= 0) Then

            l_statement := 'SELECT LINK.LINK_ID, '
                  || l_SELECT_NAME
                  || ', '
                  || l_SELECT_DETAIL
                  || ','
                  || l_SELECT_ID
                  || ', LINK.LAST_UPDATE_DATE FROM CS_TP_TEMPLATE_LINKS LINK, '
                  || l_FROM_TABLE
                  || ' WHERE '
                  || l_WHERE_CLAUSE
                  || ' AND LINK.OTHER_ID = '
                  || l_SELECT_ID
                  || ' AND LINK.TEMPLATE_ID =  '
                  || ' :P_Template_ID '
                  || ' AND LINK.OBJECT_CODE ='''
                  || P_JTF_OBJECT_CODE
                  || '''';
       Else
           l_statement := 'SELECT LINK.LINK_ID, '
                  || l_SELECT_NAME
                  || ', '
                  || l_SELECT_DETAIL
                  || ', '
                  || l_SELECT_ID
                  || ', LINK.LAST_UPDATE_DATE FROM CS_TP_TEMPLATE_LINKS LINK, '
                  || l_FROM_TABLE
                  || ' WHERE '
                  || l_WHERE_CLAUSE
                  || ' AND LINK.OTHER_ID = '
                  || l_SELECT_ID
                  || ' AND LINK.TEMPLATE_ID =  '
                  || ' :P_Template_ID '
                  || ' AND LINK.OBJECT_CODE ='''
                  || P_JTF_OBJECT_CODE
                  || '''  ORDER BY '
                  || l_ORDER_BY_CLAUSE;
       End If;
    Else -- this is for the problem code case
      If (l_ORDER_BY_CLAUSE Is Null
        Or l_ORDER_BY_CLAUSE = FND_API.G_MISS_CHAR
        Or length(l_ORDER_BY_CLAUSE)<=0 ) Then
         l_statement := 'SELECT LINK.LINK_ID, '
                 || l_SELECT_NAME
                 || ', '
                 || l_SELECT_DETAIL
                 || ','
                 || l_SELECT_ID
                 || ', LINK.LAST_UPDATE_DATE FROM CS_TP_TEMPLATE_LINKS LINK, '
                 || l_FROM_TABLE
                 || ' WHERE '
                 || l_WHERE_CLAUSE
                 || ' AND LINK.LOOKUP_CODE = '
                 || l_SELECT_ID
                 || ' AND LINK.TEMPLATE_ID =  '
                 || ' :P_Template_ID '
                 || ' AND LINK.OBJECT_CODE ='''
                 || P_JTF_OBJECT_CODE
                 || '''';
      Else
         l_statement := 'SELECT LINK.LINK_ID, '
                 || l_SELECT_NAME
                 || ', '
                 || l_SELECT_DETAIL
                 || ', '
                 || l_SELECT_ID
                 || ', LINK.LAST_UPDATE_DATE FROM CS_TP_TEMPLATE_LINKS LINK, '
                 || l_FROM_TABLE
                 || ' WHERE '
                 || l_WHERE_CLAUSE
                 || ' AND LINK.LOOKUP_CODE = '
                 || l_SELECT_ID
                 || ' AND LINK.TEMPLATE_ID =  '
                 || ' :P_Template_ID '
                 || ' AND LINK.OBJECT_CODE ='''
                 || P_JTF_OBJECT_CODE
                 || '''  ORDER BY '
                 || l_ORDER_BY_CLAUSE;
     End If;
    End If;

    l_CursorID := dbms_sql.open_cursor;
    dbms_sql.parse(l_CursorID, l_statement, dbms_sql.NATIVE);
    dbms_sql.define_column(l_CursorID, 1, L_LINK_ID);
    dbms_sql.define_column(l_CursorID, 2, L_LINK_NAME, 300);
    dbms_sql.define_column(l_CursorID, 3, L_LINK_DESC, 1000);

    If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
      dbms_sql.define_column(l_CursorID, 4, L_OTHER_ID);
    Else
      dbms_sql.define_column(l_CursorID, 4, L_OTHER_CODE, 30);
    End If;

    dbms_sql.define_column(l_CursorID, 5, L_LAST_UPDATE_DATE);

    dbms_sql.bind_variable(l_CursorID, 'P_Template_ID', P_Template_ID);

    l_total_attribute_num := dbms_sql.execute(l_CursorID);

    i:=1;
    j:=0;

    While (dbms_sql.fetch_rows(l_CursorID) > 0) Loop
     If (i >= l_start_link and i <= l_end_link) Then
       dbms_sql.column_value(l_CursorID, 1, l_link_id);
       dbms_sql.column_value(l_CursorID, 2, l_link_name);
       dbms_sql.column_value(l_CursorID, 3, l_link_desc);

       If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
         dbms_sql.column_value(l_CursorID, 4, l_other_id);
       Else
         dbms_sql.column_value(l_CursorID, 4, l_other_code);
       End If;

       dbms_sql.column_value(l_CursorID, 5, l_last_update_date);
       x_template_links (j).mLinkID          := l_link_id;
       x_template_links (j).mLinkName        :=  l_link_name;
       x_template_links (j).mLinkDesc        := l_link_desc;
       x_template_links (j).mJTF_OBJECT_CODE := p_jtf_object_code;

       If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
         x_template_links (j).mOther_ID  := l_other_id;
       Else
        x_template_links (j).LOOKUP_CODE := l_other_code;
       End If;
       x_template_links (j).mLAST_UPDATED_DATE :=
          to_char (l_last_update_date, l_default_last_up_date_format);
       j := j+1;
      else
         null;
      end if;
      i:= i+1;
    End Loop;
    dbms_sql.close_cursor(l_CursorID);

    X_Total_Link_Number := i-1;
    X_Retrieved_Link_Number := j;

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
                 p_data => x_msg_data);
END  Show_Template_Links_Two;

PROCEDURE Show_Non_Asso_Links_Two(
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN  VARCHAR   := FND_API.G_FALSE,
    p_template_id         IN  NUMBER,
    p_jtf_object_code     IN  VARCHAR2,
    p_start_link          IN  NUMBER,
    p_end_link            IN  NUMBER,
    p_link_name           IN  VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_template_link_list  OUT NOCOPY Template_Link_List,
    X_Total_Link_Number             OUT NOCOPY NUMBER,
    X_Retrieved_Link_Number         OUT NOCOPY NUMBER)

IS
    l_api_name     CONSTANT       VARCHAR2(30)   := 'Show_Non_Asso_Links_Two';
    l_api_version  CONSTANT       NUMBER         := 1.0;
    l_select_id                   VARCHAR2(60);
    l_select_name                 VARCHAR2(1000);
    l_select_detail               VARCHAR2(1000);
    l_from_table                  VARCHAR2(1000);
    l_order_by_clause             VARCHAR2(1000);
    l_where_clause                VARCHAR2(1000);

    Cursor JTF_OBJ_C (v_jtf_obj_code VARCHAR2)  Is
      Select SELECT_ID,
             SELECT_NAME,
             SELECT_DETAILS,
             FROM_TABLE,
             WHERE_CLAUSE,
             ORDER_BY_CLAUSE
      From JTF_OBJECTS_VL
      Where OBJECT_CODE = v_jtf_obj_code;

    l_statement                   VARCHAR2(2000);
    l_CursorID                    NUMBER;
    l_date_format                 VARCHAR2(60)  := FND_API.G_MISS_CHAR;
    l_LINK_NAME                   VARCHAR2(300);
    l_LINK_DETAIL                 VARCHAR2(1000);
    l_OTHER_ID                    NUMBER;
    l_OTHER_CODE                  VARCHAR2(30);
    l_LAST_UPDATE_DATE            DATE;
    l_total_attribute_num         NUMBER;
    i                             NUMBER;
    j                             NUMBER;
    l_start_link                  NUMBER;
    l_end_link                    NUMBER;

    l_inv_org_id                  NUMBER; --wei ma change
    l_product_name_1              VARCHAR2(2);
    l_product_name_2              VARCHAR2(2);
    l_product_name_case_1         varchar2(4);
    l_product_name_case_2         varchar2(4);
    l_product_name_case_3         varchar2(4);
    l_product_name_case_4         varchar2(4);
    l_link_name_length            NUMBER := 0;
    l_defined_order_exist         boolean := false;
    l_statement_two               varchar2(2000);
    l_from_number                 NUMBER;
    l_orderby_number              NUMBER;
    l_CursorID_2                 NUMBER;
    l_total_number                NUMBER;
BEGIN
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_start_link := p_start_link;
    l_end_link   := P_end_link;

    -- Check for null L_Start_Link and P_End_Link
    If (l_start_link Is Null
      Or l_start_link = FND_API.G_MISS_NUM) Then
       l_start_link := 1;
    End If;

    -- If L_End_LINK is NULL, set it to G_MISS_NUM
    -- which should be a greater than any template number
    If (l_end_link Is Null
      Or l_end_link = FND_API.G_MISS_NUM) then
       l_end_link := FND_API.G_MISS_NUM;
    End If;

    -- validation
    If (l_start_link > l_end_link
      Or l_start_link <= 0 Or l_end_link <= 0) Then
       X_Return_Status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_LINK_INQUIRY_INVALID');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    End If;

     -- Start API Body
    l_date_format := get_date_format;
    Open JTF_OBJ_C (P_JTF_OBJECT_CODE);
    Fetch JTF_OBJ_C
    Into l_SELECT_ID, l_SELECT_NAME,l_SELECT_DETAIL,
         l_FROM_TABLE,l_WHERE_CLAUSE, l_ORDER_BY_CLAUSE;
    If (JTF_OBJ_C%notfound) Then
         Close JTF_OBJ_C;
         X_Return_Status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_ATTR_JTFOB');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
    End If;
    Close JTF_OBJ_C;

    -- here add the extra query by name function, here in order to
    -- minimize the change to the original code, we try to use the
    -- L_ORDER_BY_CLAUSE

     If (l_ORDER_BY_CLAUSE is not Null and l_ORDER_BY_CLAUSE <>
         FND_API.G_MISS_CHAR and length(l_ORDER_BY_CLAUSE) > 0 ) then
           l_ORDER_BY_CLAUSE:= ' ORDER BY ' || l_ORDER_BY_CLAUSE ;
           l_defined_order_exist := true;
     end if;

     -- wei ma change
     If (P_JTF_OBJECT_CODE<>'IBU_PRODUCT' and p_link_name Is Not Null and p_link_name <> FND_API.G_MISS_CHAR
        and length(p_link_name) > 0) Then
            If (l_ORDER_BY_CLAUSE Is Null Or
               l_ORDER_BY_CLAUSE= FND_API.G_MISS_CHAR
                Or length(l_ORDER_BY_CLAUSE) <=0 ) then
            l_ORDER_BY_CLAUSE:=
                ' and '||l_SELECT_NAME|| 'like '||':p_link_name';
           else
             l_ORDER_BY_CLAUSE:=
                ' and '||l_SELECT_NAME||' like '||':p_link_name'||l_ORDER_BY_CLAUSE;
           end if;
       End If;


     If (P_JTF_OBJECT_CODE = 'IBU_PRODUCT' and p_link_name Is Not Null and p_link_name <> FND_API.G_MISS_CHAR
        and length(p_link_name) > 0) Then
            if(length(p_link_name) = 1) then
               l_product_name_1 := substr(p_link_name, 1,1);
               l_product_name_case_1 := upper(l_product_name_1)||'%';
               l_product_name_case_2 := lower(l_product_name_1)||'%';
               l_link_name_length := 1;
               if(l_defined_order_exist) then
                  l_ORDER_BY_CLAUSE:=
                   ' and upper('||l_SELECT_NAME||') like '||'upper(:p_link_name)'||' and (' ||
                   l_SELECT_NAME || ' like '||':p_product_name_case_1' || ' or '||
                   l_SELECT_NAME || ' like '||':p_product_name_case_2' || ' ) '|| l_ORDER_BY_CLAUSE;
               else
                   l_ORDER_BY_CLAUSE:=
                   ' and upper('||l_SELECT_NAME||') like '||'upper(:p_link_name)'||' and (' ||
                   l_SELECT_NAME || ' like '||':p_product_name_case_1' || ' or '||
                   l_SELECT_NAME || ' like '||':p_product_name_case_2' || ' ) ';
               end if;
            else
               l_product_name_1 := substr(p_link_name, 1,1);
               l_product_name_2 := substr(p_link_name, 2, 1);
               l_product_name_case_1 := upper(l_product_name_1)||lower(l_product_name_2)||'%';
               l_product_name_case_2 := lower(l_product_name_1)||upper(l_product_name_2)||'%';
               l_product_name_case_3 := upper(l_product_name_1)||upper(l_product_name_2)||'%';
               l_product_name_case_4 := lower(l_product_name_1)||lower(l_product_name_2)||'%';
               l_link_name_length := 2;
               if(l_defined_order_exist) then
                  l_ORDER_BY_CLAUSE:=
                   ' and upper('||l_SELECT_NAME||') like '||'upper(:p_link_name)'||' and (' ||
                   l_SELECT_NAME || ' like '||':p_product_name_case_1' || ' or '||
                   l_SELECT_NAME || ' like '||':p_product_name_case_2' || ' or '||
                   l_SELECT_NAME || ' like '||':p_product_name_case_3' || ' or '||
                   l_SELECT_NAME || ' like '||':p_product_name_case_4' || ' ) '||l_ORDER_BY_CLAUSE;
               else
                  l_ORDER_BY_CLAUSE:=
                   ' and upper('||l_SELECT_NAME||') like '||'upper(:p_link_name)'||' and (' ||
                   l_SELECT_NAME || ' like '||':p_product_name_case_1' || ' or '||
                   l_SELECT_NAME || ' like '||':p_product_name_case_2' || ' or '||
                   l_SELECT_NAME || ' like '||':p_product_name_case_3' || ' or '||
                   l_SELECT_NAME || ' like '||':p_product_name_case_4' || ' ) ' ;
               end if;
            end if;
       End If;


    If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
       If (l_ORDER_BY_CLAUSE Is Null
        Or l_ORDER_BY_CLAUSE= FND_API.G_MISS_CHAR
        Or length(l_ORDER_BY_CLAUSE) <=0 ) Then
             l_statement := 'SELECT '
                       || l_SELECT_ID
                       || ', '
                       || l_SELECT_NAME
                       ||  ', '
                       || l_SELECT_DETAIL
                       ||  ' FROM '
                       || l_FROM_TABLE
                       || ' WHERE '
                       || l_WHERE_CLAUSE
                       || ' AND '
                       || ' NOT EXISTS (SELECT '
                       || '''x'''
                       || ' FROM CS_TP_TEMPLATE_LINKS LINK WHERE  LINK.TEMPLATE_ID =  '
                       || ':P_Template_ID'
                       || ' AND LINK.OBJECT_CODE ='''
                       || P_JTF_OBJECT_CODE
                       || ''' AND LINK.OTHER_ID = '
                       || l_SELECT_ID
                       || ' ) ';
       Else

            l_statement := 'SELECT '
                       || l_SELECT_ID
                       || ', '
                       || l_SELECT_NAME
                       ||  ', '
                       || l_SELECT_DETAIL
                       || ' FROM '
                       || l_FROM_TABLE
                       || ' WHERE '
                       || l_WHERE_CLAUSE
                       || ' AND '
                       || ' NOT EXISTS (SELECT '
                       || '''x'''
                       || ' FROM CS_TP_TEMPLATE_LINKS LINK WHERE  LINK.TEMPLATE_ID =  '
                       || ':P_Template_ID'
                       || ' AND LINK.OBJECT_CODE ='''
                       || P_JTF_OBJECT_CODE
                       || ''' AND LINK.OTHER_ID = '
                       || l_SELECT_ID
                       || ' )  '
                       || l_ORDER_BY_CLAUSE;

       End If;
     Else
       If (l_ORDER_BY_CLAUSE Is Null
          Or l_ORDER_BY_CLAUSE = FND_API.G_MISS_CHAR
          Or length(l_ORDER_BY_CLAUSE) <=0 ) Then
           l_statement := 'SELECT '
                      || l_SELECT_ID
                      || ', '
                      || l_SELECT_NAME
                      ||  ', '
                      || l_SELECT_DETAIL
                      ||  ' FROM '
                      || l_FROM_TABLE
                      || ' WHERE '
                      || l_WHERE_CLAUSE
                      || ' AND '
                      || ' NOT EXISTS (SELECT '
                      || '''x'''
                      || ' FROM CS_TP_TEMPLATE_LINKS LINK WHERE  LINK.TEMPLATE_ID =  '
                      || ':P_Template_ID'
                      || ' AND LINK.OBJECT_CODE ='''
                      || P_JTF_OBJECT_CODE
                      || ''' AND LINK.LOOKUP_CODE = '
                      || l_SELECT_ID
                      || ' ) ';
        Else
            l_statement := 'SELECT '
                      || l_SELECT_ID
                      || ', '
                      || l_SELECT_NAME
                      ||  ', '
                      || l_SELECT_DETAIL
                      || ' FROM '
                      || l_FROM_TABLE
                      || ' WHERE '
                      || l_WHERE_CLAUSE
                      || ' AND '
                      || ' NOT EXISTS (SELECT '
                      || '''x'''
                      || ' FROM CS_TP_TEMPLATE_LINKS LINK WHERE  LINK.TEMPLATE_ID =  '
                      || ':P_Template_ID'
                      || ' AND LINK.OBJECT_CODE ='''
                      || P_JTF_OBJECT_CODE
                      || ''' AND LINK.LOOKUP_CODE = '
                      || l_SELECT_ID
                      || ' ) '
                      || l_ORDER_BY_CLAUSE;
         End If;
    End If;

    l_from_number := instr(l_statement, 'FROM');
    l_statement_two := 'SELECT count('
                      || l_SELECT_ID
                      ||') '
                      ||substr(l_statement, l_from_number);

    l_orderby_number := instr(l_statement_two, 'ORDER');
    if(l_orderby_number > 0) then
      l_statement_two := substr(l_statement_two, 1, l_orderby_number-1);
    end if;

    l_CursorID := dbms_sql.open_cursor;
    l_CursorID_2 := dbms_sql.open_cursor;
    dbms_sql.parse(l_CursorID, l_statement, dbms_sql.NATIVE);
    dbms_sql.parse(l_CursorID_2, l_statement_two, dbms_sql.NATIVE);


    If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
      dbms_sql.define_column(l_CursorID, 1, l_other_id);
    Else
      dbms_sql.define_column(l_CursorID, 1, l_other_code, 30);
    End If;
    dbms_sql.define_column(l_CursorID, 2, l_link_name, 300);
    dbms_sql.define_column(l_CursorID, 3, l_link_detail, 1000);

    dbms_sql.define_column(l_CursorID_2, 1, l_total_number);

    dbms_sql.bind_variable(l_CursorID, 'P_Template_ID', P_Template_ID);
    dbms_sql.bind_variable(l_CursorID_2, 'P_Template_ID', P_Template_ID);

/*   If(P_JTF_OBJECT_CODE = 'IBU_PRODUCT') Then
       l_inv_org_id := cs_std.get_item_valdn_orgzn_id();
       dbms_sql.bind_variable(l_CursorID, 'organizationID', l_inv_org_id);
       dbms_sql.bind_variable(l_CursorID_2, 'organizationID', l_inv_org_id);
    end if; */

    If (l_ORDER_BY_CLAUSE Is not Null and
              l_ORDER_BY_CLAUSE <> FND_API.G_MISS_CHAR
               and length(l_ORDER_BY_CLAUSE) > 0 )then
       If (p_link_name Is Not Null and p_link_name <> FND_API.G_MISS_CHAR
          and length(p_link_name) > 0) Then
            dbms_sql.bind_variable(l_CursorID, 'p_link_name', p_link_name||'%');
            dbms_sql.bind_variable(l_CursorID_2, 'p_link_name', p_link_name||'%');
       end if ;
    end if ;

    -- wei ma change
    if(P_JTF_OBJECT_CODE = 'IBU_PRODUCT') then
       if(l_link_name_length = 1) then
          dbms_sql.bind_variable(l_CursorID, 'p_product_name_case_1', l_product_name_case_1);
          dbms_sql.bind_variable(l_CursorID, 'p_product_name_case_2', l_product_name_case_2);
          dbms_sql.bind_variable(l_CursorID_2, 'p_product_name_case_1', l_product_name_case_1);
          dbms_sql.bind_variable(l_CursorID_2, 'p_product_name_case_2', l_product_name_case_2);
       end if;
       if(l_link_name_length = 2) then
          dbms_sql.bind_variable(l_CursorID, 'p_product_name_case_1', l_product_name_case_1);
          dbms_sql.bind_variable(l_CursorID, 'p_product_name_case_2', l_product_name_case_2);
          dbms_sql.bind_variable(l_CursorID, 'p_product_name_case_3', l_product_name_case_3);
          dbms_sql.bind_variable(l_CursorID, 'p_product_name_case_4', l_product_name_case_4);
          dbms_sql.bind_variable(l_CursorID_2, 'p_product_name_case_1', l_product_name_case_1);
          dbms_sql.bind_variable(l_CursorID_2, 'p_product_name_case_2', l_product_name_case_2);
          dbms_sql.bind_variable(l_CursorID_2, 'p_product_name_case_3', l_product_name_case_3);
          dbms_sql.bind_variable(l_CursorID_2, 'p_product_name_case_4', l_product_name_case_4);
       end if;
    end if;

    l_total_attribute_num := dbms_sql.execute(l_CursorID);
    l_total_number := dbms_sql.execute(l_CursorID_2);

    i:=1;
    j:=0;

    While (dbms_sql.fetch_rows(l_CursorID) > 0) Loop

      if(i > l_end_link) then
         exit;
      end if;
      If (i >= l_start_link and i <= l_end_link) Then
        If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
          dbms_sql.column_value(l_CursorID, 1, l_other_id);
        Else
          dbms_sql.column_value(l_CursorID, 1, l_other_code);
        End If;
        dbms_sql.column_value(l_CursorID, 2, l_link_name);
        dbms_sql.column_value(l_CursorID, 3, l_link_detail);
        If(P_JTF_OBJECT_CODE <> 'IBU_TP_SR_PROBCODE') Then
          x_template_link_list (i).mOther_ID := l_other_id;
        Else
          x_template_link_list (i).LOOKUP_CODE := l_other_code;
        End If;
        x_template_link_list (i).mLinkName :=  l_link_name;
        x_template_link_list (i).mLinkDesc := l_link_detail;
        j:= j+1;
      else
         null;
      end if;

      i:= i+1;
    End Loop;

    dbms_sql.close_cursor(l_CursorID);

    While (dbms_sql.fetch_rows(l_CursorID_2) > 0) Loop
      dbms_sql.column_value(l_CursorID_2, 1, l_total_number);
    end loop;
    dbms_sql.close_cursor(l_CursorID_2);

    --X_Total_Link_Number := i-1;'
    X_Total_Link_Number := l_total_number;
    X_Retrieved_Link_Number := j;

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
                 p_data => x_msg_data
                );
END Show_Non_Asso_Links_Two;



PROCEDURE Delete_Template_Links (
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR   := FND_API.G_FALSE,
    p_template_id            IN  NUMBER,
    p_jtf_object_code        IN  VARCHAR2,
    p_template_links         IN  Template_Link_List,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2)
IS

  l_api_name     CONSTANT       VARCHAR2(30) := 'Update_Template_Links';
  l_api_version  CONSTANT       NUMBER       := 1.0;
  l_JTF_OBJECT_CursorID         NUMBER;
  l_JTF_OBJECT_CODE_count       NUMBER;
  l_template_count_with_id      NUMBER;
  l_One_Template_Link           Template_Link;
  i                             NUMBER;
  CURSOR C IS
     Select count(*)
     From CS_TP_TEMPLATES_B
     Where template_id = P_Template_ID;

BEGIN
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- perform validation, see if template id is valid
  Open C;
  Fetch C Into l_template_count_with_id;
  If (l_template_count_with_id <=0 ) Then
       Close C;
        X_Return_Status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_Link_TID_INV');
        FND_MSG_PUB.Add;
       Raise FND_API.G_EXC_ERROR  ;
  End If;
  Close C;

  If (P_Template_Links.COUNT >0) Then
      For i In P_Template_Links.FIRST..P_Template_Links.LAST Loop
         l_One_Template_Link := P_Template_Links (i);
         CS_TP_TEMPLATE_LINKS_PKG.DELETE_ROW
              ( X_LINK_ID =>l_One_Template_Link.mLinkID);
      End Loop;
   End If;

  IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data);
END Delete_Template_Links;


PROCEDURE Add_Template_Links (
    p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR   := FND_API.G_FALSE,
    p_template_id            IN  NUMBER,
    p_jtf_object_code        IN  VARCHAR2,
    p_template_links         IN  Template_Link_List,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2)
IS
  l_api_name     CONSTANT       VARCHAR2(30) := 'Add_Template_Links';
  l_api_version  CONSTANT       NUMBER       := 1.0;
  l_JTF_OBJECT_CursorID         NUMBER;
  l_JTF_OBJECT_CODE_count       NUMBER;
  l_current_date                DATE         :=FND_API.G_MISS_DATE;
  l_created_by                  NUMBER       :=FND_API.G_MISS_NUM;
  l_login                       NUMBER       :=FND_API.G_MISS_NUM;
  l_Row_ID                      VARCHAR2(30);
  l_New_Link_id                 NUMBER;
  l_One_Template_Link           Template_Link;
  l_template_count_with_id      NUMBER;
  l_stmt                        VARCHAR2(100);
  i                             NUMBER;
  CURSOR C IS
     Select count(*)
     From CS_TP_TEMPLATES_B
     Where template_id = P_Template_ID;

BEGIN
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- perform validation, see if template id is valid
  Open C;
  Fetch C Into l_template_count_with_id;
  If (l_template_count_with_id <=0 ) Then
       Close C;
        X_Return_Status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS','CS_TP_TEMPLATE_Link_TID_INV');
        FND_MSG_PUB.Add;
       Raise FND_API.G_EXC_ERROR  ;
  End If;
  Close C;
  l_current_date := sysdate;
  l_created_by   := fnd_global.user_id;
  l_login        := fnd_global.login_id;

  --loop through each link.  If the link id is present, perform an update.
  If (P_Template_Links.COUNT >0) Then
    For i In P_Template_Links.FIRST..P_Template_Links.LAST Loop
      l_One_Template_Link := P_Template_Links (i);
      -- If the link_id is passed, modify the row, otherwise insert the row.

      If (l_One_Template_Link.mLinkID Is Null
        Or l_One_Template_Link.mLinkID = FND_API.G_MISS_NUM) Then

        --Get the template id from the next available sequence number
        Select CS_TP_TEMPLATE_LINKS_S.nextval Into l_New_Link_id From dual;
        CS_TP_TEMPLATE_LINKS_PKG.INSERT_ROW (
               x_rowid              => l_Row_ID ,
               x_link_id            => l_New_Link_id,
               x_template_id        => P_Template_ID,
               x_other_id           => l_One_Template_Link.mOther_ID,
               x_lookup_code        => l_One_Template_Link.lookup_Code,
               x_lookup_type        => l_One_Template_Link.Lookup_Type,
               x_object_code        => l_One_Template_Link.mJTF_OBJECT_CODE,
               x_creation_date      => l_current_date,
               x_created_by         => l_created_by,
               x_last_update_date   => l_current_date,
               x_last_updated_by    => l_created_by,
               x_last_update_login  => l_login);
      Else
        CS_TP_TEMPLATE_LINKS_PKG.UPDATE_ROW (
               x_link_id            => l_One_Template_Link.mLinkID,
               x_template_id        => P_Template_ID,
               x_other_id           => l_One_Template_Link.mOther_ID,
               x_lookup_code        => l_One_Template_Link.lookup_Code,
               x_lookup_type        => l_One_Template_Link.Lookup_Type,
               x_object_code        => l_One_Template_Link.mJTF_OBJECT_CODE,
               x_last_update_date   => l_current_date,
               x_last_updated_by    => l_created_by,
               x_last_update_login  => l_login);

        End If;
      End loop;
   End If;  --P_Template_Links.count>0

  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count ,
                             p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data);
END Add_Template_Links;


END  CS_TP_TEMPLATES_PVT;

/
