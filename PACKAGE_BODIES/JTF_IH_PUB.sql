--------------------------------------------------------
--  DDL for Package Body JTF_IH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_PUB" AS
/* $Header: JTFIHPBB.pls 120.4.12010000.2 2008/11/25 10:00:00 ppillai ship $ */
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_IH_PUB';


-- 08/26/03 mpetrosi B3102306
-- added cross check of source_code, source_code_id
PROCEDURE Validate_Source_Code(p_api_name IN VARCHAR2
  ,x_source_code_id IN OUT NOCOPY NUMBER
  ,x_source_code IN OUT NOCOPY VARCHAR2
  ,x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Source_Code(p_api_name IN VARCHAR2
  ,x_source_code_id IN OUT NOCOPY NUMBER
  ,x_source_code IN OUT NOCOPY VARCHAR2
  ,x_return_status IN OUT NOCOPY VARCHAR2)  IS
BEGIN

   IF ((x_source_code_id IS NOT NULL) AND
       (x_source_code_id <> fnd_api.g_miss_num)) AND
       ((x_source_code IS NULL) OR
        (x_source_code = fnd_api.g_miss_char)) THEN
      BEGIN
        SELECT source_code into x_source_code
          FROM ams_source_codes
          WHERE source_code_id = x_source_code_id;
        IF (SQL%NOTFOUND) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(x_source_code_id), 'SOUREC_CODE');
          RETURN ;
        END IF;
      END;
   END IF;

   IF ((x_source_code IS NOT NULL) AND
       (x_source_code <> fnd_api.g_miss_char)) AND
      ((x_source_code_id IS NULL) OR
       (x_source_code_id = fnd_api.g_miss_num)) THEN
      BEGIN
         SELECT source_code_id into x_source_code_id
         FROM ams_source_codes
         WHERE source_code = x_source_code;
         IF (SQL%NOTFOUND) THEN
            x_return_status := fnd_api.g_ret_sts_error;
            jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, x_source_code, 'SOURCE_CODE');
            RETURN;
         END IF;
      END;
   END IF;

END Validate_Source_Code;


-- Jean Zhu add Utility Validate_StartEnd_Date
PROCEDURE Validate_StartEnd_Date
(  p_api_name         IN     VARCHAR2,
   p_start_date_time  IN     DATE,
   p_end_date_time    IN     DATE,
   x_return_status    IN OUT NOCOPY  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition
--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	Jean Zhu	11-JAN-2000	INITIAL VERSION
--	James Baldo Jr.	03-MAY-2000	Fix for bugdb 1286036
--  Enh# 2999069 - time portion not included in start and end date time
--  error messages

PROCEDURE Validate_StartEnd_Date
  ( p_api_name    IN     VARCHAR2,
    p_start_date_time   IN     DATE,
    p_end_date_time		  IN     DATE,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  )
  IS
  BEGIN
	-- DBMS_OUTPUT.PUT_LINE('end_date =' || to_char(p_end_date_time, 'DD-MON-YYYY') || ' start_date =' ||  to_char(p_start_date_time, 'DD-MON-YYYY'));
	IF((p_start_date_time IS NOT NULL) AND (p_end_date_time IS NOT NULL) AND
		(p_start_date_time <> fnd_api.g_miss_date) AND
		(p_end_date_time <> fnd_api.g_miss_date) AND
--		(p_end_date_time - p_start_date_time < 0) )THEN
		(p_end_date_time < p_start_date_time) )THEN
			-- DBMS_OUTPUT.PUT_LINE('end_date is less than start_date in JTF_IH_PUB.Validate_StartEnd_Date');
			x_return_status := fnd_api.g_ret_sts_error;
--      jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_end_date_time, 'DD-MON-YYYY'),
--					    'end_date_time');
      -- Enh# 2999069
      --jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_end_date_time, 'DD-MON-RRRR HH:MI:SS'),'end_date_time');
      FND_MESSAGE.SET_NAME('JTF','JTF_IH_API_INVALID_END_DATE');
      FND_MESSAGE.SET_TOKEN('END_DATE', to_char(p_end_date_time, 'DD-MON-RRRR HH:MI:SS'));
      FND_MESSAGE.SET_TOKEN('START_DATE', to_char(p_start_date_time, 'DD-MON-RRRR HH:MI:SS'));
      FND_MSG_PUB.Add;
	END IF;
  END Validate_StartEnd_Date;


  PROCEDURE Validate_Interaction_Record
  ( p_api_name    IN     VARCHAR2,
    p_int_val_rec       IN OUT NOCOPY interaction_rec_type,
    p_resp_appl_id      IN     NUMBER   := NULL,
    p_resp_id     IN     NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  );

--	HISTORY
--
--	AUTHOR		     DATE		  MODIFICATION DESCRIPTION
--	------		     ----		  --------------------------
--  Prashanth Pillai     20-MAY-2008              FIX 7028381
--
  FUNCTION Is_ContactPartyEmployeeOfOrg(p_Party_id IN NUMBER
  )RETURN BOOLEAN AS
  s_Employee_Number VARCHAR2(30) := NULL;
  BEGIN
  SELECT DISTINCT PERSON_ID INTO s_Employee_Number FROM PER_WORKFORCE_CURRENT_X WHERE PARTY_ID = p_Party_id;
  RETURN TRUE;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
    END;

--
--	HISTORY
--
--	AUTHOR		     DATE		  MODIFICATION DESCRIPTION
--	------		     ----		  --------------------------
--  Igor Aleshin     17-JUN-2003   Created based on Enh# 1846960
--
    FUNCTION Get_Party_Type( p_Party_Id       IN      NUMBER
    ) RETURN VARCHAR2 AS
  s_Party_Type VARCHAR2(30) := NULL;
    BEGIN
  SELECT PARTY_TYPE INTO s_Party_Type FROM HZ_PARTIES WHERE PARTY_ID = p_Party_Id;
  RETURN s_Party_Type;
    EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    END;

--
--	HISTORY
--
--	AUTHOR		     DATE		  MODIFICATION DESCRIPTION
--	------		     ----		  --------------------------
--  Igor Aleshin     17-JUN-2003   Created based on Enh# 1846960
--

PROCEDURE Get_Relationship(p_Party_ID IN NUMBER,
   p_Subject_ID OUT NOCOPY NUMBER,
   p_Subject_Type OUT NOCOPY VARCHAR2,
   p_Object_ID OUT NOCOPY NUMBER,
   p_Object_Type OUT NOCOPY VARCHAR2,
   x_return_status IN OUT NOCOPY  VARCHAR2
) AS

  l_direction_flag_perf VARCHAR2(1); -- Perf fix for literal Usage
BEGIN

   -- Get a Party relationship ids: Subject_ID and Subject_Type and
   -- Object_Id and Object_Type
   --
   -- Perf fix for literal Usage
   l_direction_flag_perf := 'F';

   SELECT
      SUBJECT_ID,
      SUBJECT_TYPE,
      OBJECT_ID,
      OBJECT_TYPE
   INTO
      p_Subject_ID,
      p_Subject_Type,
      p_Object_ID,
      p_Object_Type
   FROM HZ_RELATIONSHIPS WHERE PARTY_ID = p_Party_ID AND
      DIRECTIONAL_FLAG = l_direction_flag_perf;
   x_return_status := fnd_api.g_ret_sts_success;
   RETURN;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_return_status := fnd_api.g_ret_sts_error;
     FND_MESSAGE.SET_NAME('JTF','JTF_IH_NO_PARTY_RELATIONSHIP');
     FND_MESSAGE.SET_TOKEN('PARTY', p_Party_ID);
     FND_MSG_PUB.Add;
     RETURN;
END;

--
--	HISTORY
--
--	AUTHOR		     DATE		  MODIFICATION DESCRIPTION
--	------		     ----		  --------------------------
--  Igor Aleshin     17-JUN-2003   Created based on Enh# 1846960
--
PROCEDURE Validate_SinglePartyID(
  p_int_val_rec       IN OUT NOCOPY  interaction_rec_type,
  x_return_status     IN OUT NOCOPY  VARCHAR2
) AS
  s_Party_Type VARCHAR2(30);
  n_Subject_Id NUMBER;
  s_Subject_Type VARCHAR2(30);
  n_Object_ID NUMBER;
  s_Object_Type VARCHAR2(30);

BEGIN
  -- Get Party Type
  --
  s_Party_Type := Get_Party_Type(p_int_val_rec.party_id);

  -- Party Type based on required Party Id. If Party Type is null then
  -- return an error.
  --
  IF s_Party_Type IS NULL THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('JTF','JTF_IH_NO_PARTY');
      FND_MESSAGE.SET_TOKEN('PARTY', p_int_val_rec.party_id);
      FND_MSG_PUB.Add;
      RETURN;
  END IF;

  -- Case# 1 - Person as customer - Same person Contac
  --
  IF s_Party_Type = 'PERSON' THEN
    p_int_val_rec.primary_party_id := p_int_val_rec.party_id;
    p_int_val_rec.contact_rel_party_id := NULL;
    p_int_val_rec.contact_party_id := p_int_val_rec.party_id;
    x_return_status := fnd_api.g_ret_sts_success;
    RETURN;
  -- Case# 3 - Org as Customer. No Contact
  --
  ELSIF s_Party_Type = 'ORGANIZATION' THEN
    p_int_val_rec.primary_party_id := p_int_val_rec.party_id;
    p_int_val_rec.contact_rel_party_id := NULL;
    p_int_val_rec.contact_party_id := NULL;
    x_return_status := fnd_api.g_ret_sts_success;
    RETURN;
  ELSIF s_Party_Type = 'PARTY_RELATIONSHIP' THEN
      -- Check valid relationship
      --
      Get_Relationship(p_int_val_rec.party_id,n_Subject_Id,s_Subject_Type,
                       n_Object_Id,s_Object_Type, x_return_status);
      IF x_return_status = fnd_api.g_ret_sts_error THEN
    RETURN;
      ELSE
    -- Case# 2 Person as customer - Other Person Contact
    --
    IF(s_Object_Type = 'PERSON') and (s_Subject_Type = 'PERSON') THEN
        p_int_val_rec.primary_party_id := p_int_val_rec.party_id;
        p_int_val_rec.contact_rel_party_id := p_int_val_rec.party_id;
        p_int_val_rec.contact_party_id := NULL;
    -- Case# 4 Org. as Customer - Person Contact
    --
    ELSIF(s_Object_Type = 'ORGANIZATION') and (s_Subject_Type = 'PERSON') THEN
        p_int_val_rec.primary_party_id := n_Object_Id;
        p_int_val_rec.contact_rel_party_id := p_int_val_rec.party_id;
        p_int_val_rec.contact_party_id := n_Subject_Id;
    ELSIF (s_Subject_Type = 'ORGANIZATION') and (s_Object_Type = 'PERSON') THEN
        p_int_val_rec.primary_party_id := n_Subject_Id;
        p_int_val_rec.contact_rel_party_id := p_int_val_rec.party_id;
        p_int_val_rec.contact_party_id := n_Object_Id;
    ELSIF (s_Subject_Type = 'ORGANIZATION') and (s_Object_Type = 'ORGANIZATION') THEN
        p_int_val_rec.primary_party_id := p_int_val_rec.party_id;
        p_int_val_rec.contact_rel_party_id := NULL;
        p_int_val_rec.contact_party_id := NULL;
    ELSE
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_WRONG_PARTY_REL');
        FND_MESSAGE.SET_TOKEN('PARTY_ID', p_int_val_rec.party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;
      END IF;
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;
  RETURN;
END;

--
--	HISTORY
--
--	AUTHOR		     DATE		  MODIFICATION DESCRIPTION
--	------		     ----		  --------------------------
--  Igor Aleshin     17-JUN-2003   Created based on Enh# 1846960
--
    PROCEDURE Validate_MultiPartyID(
    p_int_val_rec       IN interaction_rec_type,
    x_return_status     IN OUT NOCOPY  VARCHAR2
    ) AS
  s_Party_Type VARCHAR2(30);
  n_Subject_Id NUMBER;
  s_Subject_Type VARCHAR2(30);
  n_Object_ID NUMBER;
  s_Object_Type VARCHAR2(30);
    BEGIN
    	-- Reject invalid combinations
    	--
  IF p_int_val_rec.primary_party_id IS NULL THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('JTF','JTF_IH_REQ_ITEM_MSG');
      FND_MESSAGE.SET_TOKEN('FIELDNAME', 'Primary_Party_ID');
      FND_MSG_PUB.Add;
      RETURN;
  END IF;

  -- Check valid combination for Contact_Party_ID and Primary_Party_Id and Contact_Rel_Party_ID
  --
		IF p_int_val_rec.Contact_Party_ID IS NULL AND
      p_int_val_rec.Primary_Party_Id IS NOT NULL
      AND p_int_val_rec.Contact_Rel_Party_ID IS NOT NULL THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('JTF','JTF_IH_INVALID_PARTY_COMB');
    FND_MSG_PUB.Add;
    RETURN;
  END IF;

  -- If the Party_Id is not equals to one of the other party id values them it must be validated separately - Case #5 and #6
		--
  IF (p_int_val_rec.party_id <> p_int_val_rec.primary_party_id) AND
      (p_int_val_rec.party_id <> nvl(p_int_val_rec.contact_rel_party_id,-1)) AND
      (p_int_val_rec.party_id <> nvl(p_int_val_rec.contact_party_id,-1)) THEN
    s_Party_Type := Get_Party_Type(p_int_val_rec.party_id);

    IF s_Party_Type IS NULL THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_NO_PARTY');
        FND_MESSAGE.SET_TOKEN('PARTY', p_int_val_rec.party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;

    IF s_Party_Type <> 'ORGANIZATION' THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_PARTIES_NOT_EQUAL');
        FND_MESSAGE.SET_TOKEN('PARTY_ID', p_int_val_rec.party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;
  END IF;
  -- Validate cases no contact_rel_party_id is passed Case#1, Case#3, Case#5
  IF (p_int_val_rec.contact_rel_party_id IS NULL) THEN
   IF ((p_int_val_rec.contact_party_id IS NOT NULL) AND (p_int_val_rec.primary_party_id IS NOT NULL)) THEN
    IF((Is_ContactPartyEmployeeOfOrg(p_int_val_rec.contact_party_id) = FALSE)
        AND (p_int_val_rec.primary_party_id <> p_int_val_rec.contact_party_id)) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_INVALID_PERSON_PARTY');
        FND_MESSAGE.SET_TOKEN('P_PARTY_ID', p_int_val_rec.party_id);
        FND_MESSAGE.SET_TOKEN('C_PARTY_ID', p_int_val_rec.contact_party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;

    -- Get Contact Party Type
    --
    s_Party_Type := Get_Party_Type(p_int_val_rec.contact_party_id);
    IF s_Party_Type IS NULL THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_NO_PARTY');
        FND_MESSAGE.SET_TOKEN('PARTY', p_int_val_rec.contact_party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;
    IF s_Party_Type <> 'PERSON' THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_NON_PERSON_CONTACT');
        FND_MESSAGE.SET_TOKEN('C_PARTY_ID', p_int_val_rec.contact_party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;
    x_return_status := fnd_api.g_ret_sts_success;
    RETURN;
      END IF;

      IF p_int_val_rec.contact_party_id IS NULL THEN -- Case# 3, 5
    s_Party_Type := Get_Party_Type(p_int_val_rec.primary_party_id);
    IF s_Party_Type IS NULL THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_NO_PARTY');
        FND_MESSAGE.SET_TOKEN('PARTY', p_int_val_rec.primary_party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;
    IF s_Party_Type <> 'ORGANIZATION' THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_INVALID_PERSON_PARTY');
        FND_MESSAGE.SET_TOKEN('P_PARTY_ID', p_int_val_rec.primary_party_id);
        FND_MESSAGE.SET_TOKEN('C_PARTY_ID', p_int_val_rec.contact_party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;
    x_return_status := fnd_api.g_ret_sts_success;
    RETURN;
      END IF;
  END IF;

  -- Check and get valid relationship for Contact_Party_Id
  --
  Get_Relationship(p_int_val_rec.contact_rel_party_id,
    n_Subject_ID,
    s_Subject_Type,
    n_Object_ID,
    s_Object_Type,
    x_return_status);

  IF x_return_status = fnd_api.g_ret_sts_error THEN
      RETURN;
  END IF;

  -- First validate the contact id to make sure is is part of the relationsip and is of type person
  -- Is the contact the object?
  --
  IF p_int_val_rec.contact_party_id = n_Object_ID THEN
      -- The Contact is the object in the relationship
      IF s_Object_Type <> 'PERSON' THEN
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_NON_PERSON_CONTACT');
        FND_MESSAGE.SET_TOKEN('C_PARTY_ID', p_int_val_rec.contact_party_id);
        FND_MSG_PUB.Add;
        RETURN;
      END IF;

      -- Validate the primary
      --
      IF p_int_val_rec.primary_party_id = n_Subject_Id THEN
    IF s_Subject_Type IN ('PERSON','ORGANIZATION') THEN
        x_return_status := fnd_api.g_ret_sts_success;
        RETURN;
    ELSE
        -- The primary is not a PERSON or an ORGANIZATION
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_INVALID_PRIMARY_ID');
        FND_MESSAGE.SET_TOKEN('P_PARTY_ID', p_int_val_rec.primary_party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;
      ELSE
        -- The primary_Id is not part of the relationship
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_PRIMARY_IS_NOT_REL');
        FND_MESSAGE.SET_TOKEN('P_PARTY_ID', p_int_val_rec.primary_party_id);
        FND_MESSAGE.SET_TOKEN('R_PARTY_ID', p_int_val_rec.contact_rel_party_id);
        FND_MSG_PUB.Add;
        RETURN;
      END IF;
  ELSE
      -- Is contact_party_id the subject?
      IF p_int_val_rec.contact_party_id = n_Subject_Id THEN
    -- The contact_party_id is subject in the relationship
    IF s_Subject_Type <> 'PERSON' THEN
        -- The contact is not a Person
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_NON_PERSON_CONTACT');
        FND_MESSAGE.SET_TOKEN('C_PARTY_ID', p_int_val_rec.contact_party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;
    IF p_int_val_rec.primary_party_id = n_Object_id THEN
        IF s_Object_Type IN ('PERSON','ORGANIZATION') THEN
      x_return_status := fnd_api.g_ret_sts_success;
      RETURN;
        ELSE
      -- The Primary is not part of the relatioship
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MESSAGE.SET_NAME('JTF','JTF_IH_INVALID_PRIMARY_ID');
      FND_MESSAGE.SET_TOKEN('P_PARTY_ID', p_int_val_rec.primary_party_id);
      FND_MSG_PUB.Add;
      RETURN;
        END IF;
    ELSE
        -- The Primary is not part of the relatioship
        x_return_status := fnd_api.g_ret_sts_error;
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_PRIMARY_IS_NOT_REL');
        FND_MESSAGE.SET_TOKEN('P_PARTY_ID', p_int_val_rec.primary_party_id);
        FND_MESSAGE.SET_TOKEN('R_PARTY_ID', p_int_val_rec.contact_rel_party_id);
        FND_MSG_PUB.Add;
        RETURN;
    END IF;
      ELSE
    -- The Contact is not part of the relationship
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MESSAGE.SET_NAME('JTF','JTF_IH_CONTACT_IS_NOT_REL');
    FND_MESSAGE.SET_TOKEN('C_PARTY_ID', p_int_val_rec.contact_party_id);
    FND_MESSAGE.SET_TOKEN('R_PARTY_ID', p_int_val_rec.contact_rel_party_id);
    FND_MSG_PUB.Add;
    RETURN;
      END IF;
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;
  RETURN;
    END;

--  End Utilities Declaration
-- Begin Utilities Definition


--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	Jean Zhu	11-JAN-2000	INITIAL VERSION
--	James Baldo Jr.	02-MAY-2000	Modified to validate AMS campaigns
--	James Baldo Jr. 11-FEB-2001	Implementation fix for bugdb # 1637335 Bind Variable party_id
--  Igor Aleshin    20-MAY-2002 Added check for Touchpoint1_type and Touchpoint2_type
--  Igor Aleshin    08-NOV-2002 Added hint NOCOPY to IN/OUT, OUT parameters
--  Igor Aleshin    18-JUN-2003 Enh# 1846960 - REQUIRE CONTACT NAME OF ORGANISATION IN INTERACTION HISTORY
--

  PROCEDURE Validate_Interaction_Record
  ( p_api_name    IN      VARCHAR2,
    p_int_val_rec       IN OUT NOCOPY interaction_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  )
  IS
    l_count 	NUMBER := 0;
    v_party_id	NUMBER;
  BEGIN
    -- local variable initialization to remove GSCC warnings
    v_party_id := p_int_val_rec.party_id;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

  --Enh# 1846960
  --
  -- Party_ID is required parameter for Interaction.
  -- Check, that Party_Id in the Interaction_Res has passed values.
  --
  IF p_int_val_rec.party_id IS NULL THEN
  x_return_status := fnd_api.g_ret_sts_error;
  FND_MESSAGE.SET_NAME('JTF','JTF_IH_NO_PARTY');
		FND_MESSAGE.SET_TOKEN('PARTY', p_int_val_rec.party_id);
  FND_MSG_PUB.Add;
  RETURN;
  ELSE

    IF( p_int_val_rec.primary_party_id = fnd_api.g_miss_num) THEN
      p_int_val_rec.primary_party_id := NULL;
    END IF;
    IF( p_int_val_rec.contact_rel_party_id = fnd_api.g_miss_num) THEN
      p_int_val_rec.contact_rel_party_id := NULL;
    END IF;
    IF( p_int_val_rec.contact_party_id = fnd_api.g_miss_num) THEN
      p_int_val_rec.contact_party_id := NULL;
    END IF;

    --fix for bug 5006885 restoring touchpoint1_type EMPLOYEE
    IF (p_int_val_rec.touchpoint1_type = 'PARTY') then
      IF ((p_int_val_rec.primary_party_id IS NULL)
        AND (p_int_val_rec.contact_rel_party_id IS NULL)
        AND (p_int_val_rec.contact_party_id IS NULL)) THEN
        Validate_SinglePartyID(p_int_val_rec, x_return_status);

      ELSE
        Validate_MultiPartyID(p_int_val_rec, x_return_status);
      END IF;
    ELSE
      BEGIN
        SELECT count(resource_id) into l_count
        FROM jtf_rs_resource_extns
        WHERE resource_id = p_int_val_rec.party_id;
        IF (l_count <= 0) THEN
             x_return_status := fnd_api.g_ret_sts_error;
             jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.resource_id),
                              'resource_id touchpoint1_type');
          RETURN;
        END IF;
      END;
    END IF;

    --  If we have any errors in the Single or Multiple Party ID procedures,
    --  then cancel procedure's process.
    IF x_return_status = fnd_api.g_ret_sts_error THEN
  RETURN;
    END IF;
  END IF;


  IF ((p_int_val_rec.handler_id IS NOT NULL) AND (p_int_val_rec.handler_id <> fnd_api.g_miss_num)) THEN
   	 BEGIN
   	     SELECT count(application_id) into l_count
       FROM fnd_application
       WHERE application_id = p_int_val_rec.handler_id;
       IF (l_count <= 0) THEN
     	x_return_status := fnd_api.g_ret_sts_error;
     	jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.handler_id),
					    'Handler_id');
		RETURN;
	     END IF;
   END;
   ELSE
   	  x_return_status := fnd_api.g_ret_sts_error;
    jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.handler_id),
					    'handler_id');
	  RETURN;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate handler_id in JTF_IH_PUB.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.resource_id IS NOT NULL) AND (p_int_val_rec.resource_id <> fnd_api.g_miss_num)) THEN
   	IF ((p_int_val_rec.touchpoint2_type <> 'PARTY') AND (p_int_val_rec.touchpoint2_type IS NOT NULL)) then
   	   BEGIN
   	     SELECT count(resource_id) into l_count
       FROM jtf_rs_resource_extns
       WHERE resource_id = p_int_val_rec.resource_id;
       IF (l_count <= 0) THEN
     	x_return_status := fnd_api.g_ret_sts_error;
     	jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.resource_id),
					    'resource_id touchpoint2_type');
	     RETURN;
	     END IF;
  END;
  ELSE
  BEGIN
   	     SELECT count(party_id) into l_count
       FROM hz_parties
       WHERE party_id = p_int_val_rec.resource_id;
       IF (l_count <= 0) THEN
     	x_return_status := fnd_api.g_ret_sts_error;
     	jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.resource_id),
					    'party_id touchpoint2_type');
	  RETURN;
	     END IF;
  END;
  END IF;
    ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.resource_id),
					    'resource_id');
	   RETURN;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate resource_id in JTF_IH_PUB.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.outcome_id IS NOT NULL) AND (p_int_val_rec.outcome_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(outcome_id) into l_count
       FROM jtf_ih_outcomes_B
       WHERE outcome_id = p_int_val_rec.outcome_id;
       IF (l_count <= 0) THEN
     	x_return_status := fnd_api.g_ret_sts_error;
     	jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.outcome_id),
					    'outcome_id');
		RETURN;
	     END IF;
   	   END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate outcome_id in JTF_IH_PUB.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.result_id IS NOT NULL) AND (p_int_val_rec.result_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(result_id) into l_count
   FROM jtf_ih_results_B
   WHERE result_id = p_int_val_rec.result_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.result_id),
					    'result_id');
					 RETURN;
					 END IF;

       END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate result_id in JTF_IH_PUB.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.reason_id IS NOT NULL) AND (p_int_val_rec.reason_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(reason_id) into l_count
   FROM jtf_ih_reasons_B
   WHERE reason_id = p_int_val_rec.reason_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.reason_id),
					    'reason_id');
					 RETURN;
					 END IF;
       END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate reason_id in JTF_IH_PUB.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.script_id IS NOT NULL) AND (p_int_val_rec.script_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(script_id) into l_count
   FROM jtf_ih_scripts
   WHERE script_id = p_int_val_rec.script_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.script_id),
					    'Script_id');
					 RETURN;
					 END IF;
       END;
   END IF;
	 -- DBMS_OUTPUT.PUT_LINE('PAST Validate script_id in JTF_IH_PUB.Validate_Interaction_Record');

-- Add by Jean Zhu to validate the source_code_id
-- Validate AMS_Source_Code table primary key source_code_id for the following permutation:
--			source_code_id does have a value
--			source_code    does not have a value
--
	l_count := 0;
	IF ((p_int_val_rec.source_code_id IS NOT NULL) AND
		(p_int_val_rec.source_code_id <> fnd_api.g_miss_num)) AND
		((p_int_val_rec.source_code IS NULL) OR
		(p_int_val_rec.source_code = fnd_api.g_miss_char)) THEN
		BEGIN
			SELECT
				count(source_code_id) into l_count
			FROM
				ams_source_codes
			WHERE
				source_code_id = p_int_val_rec.source_code_id;
			  IF (l_count <= 0) THEN
			  	x_return_status := fnd_api.g_ret_sts_error;
			  	jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.source_code_id), 'SOURCE_CODE_ID');
				  RETURN;
			  END IF;
 		END;
	END IF;


-- Validate AMS_Source_Code table primary key source_code_id for the following permutation:
--			source_code_id does not have a value
--			source_code    does  have a value
--
	l_count := 0;
	IF ((p_int_val_rec.source_code IS NOT NULL) AND
		(p_int_val_rec.source_code <> fnd_api.g_miss_char)) AND
		((p_int_val_rec.source_code_id IS NULL) OR
		(p_int_val_rec.source_code_id = fnd_api.g_miss_num)) THEN
		BEGIN
			SELECT
				count(source_code_id) into l_count
			FROM
				ams_source_codes
			WHERE
				source_code = p_int_val_rec.source_code;
			IF (l_count <= 0) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_int_val_rec.source_code, 'SOURCE_CODE');
				RETURN;
			END IF;
      		END;
	END IF;

-- Validate AMS_Source_Code table primary key source_code_id for the following permutation:
--			source_code_id does have a value
--			source_code    does have a value
--
	l_count := 0;
	IF ((p_int_val_rec.source_code IS NOT NULL) AND
		(p_int_val_rec.source_code <> fnd_api.g_miss_char)) AND
		((p_int_val_rec.source_code_id IS NOT NULL) AND
		(p_int_val_rec.source_code_id <> fnd_api.g_miss_num)) THEN
		BEGIN
			SELECT
				count(source_code_id) into l_count
			FROM
				ams_source_codes
			WHERE
				source_code    = p_int_val_rec.source_code AND
				source_code_id = p_int_val_rec.source_code_id;
			IF (l_count <= 0) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_int_val_rec.source_code || '  ' || to_char(p_int_val_rec.source_code_id),
					    		'SOURCE_CODE, SOURCE_CODE_ID');
				RETURN;
			END IF;
      		END;
	END IF;

   -- DBMS_OUTPUT.PUT_LINE('PAST Validate source_code_id in JTF_IH_PUB.Validate_Interaction_Record');

   l_count := 0;
   IF ((p_int_val_rec.parent_id IS NOT NULL) AND (p_int_val_rec.parent_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(interaction_id) into l_count
   FROM jtf_ih_interactions
   WHERE interaction_id = p_int_val_rec.parent_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_int_val_rec.parent_id),
					    'interaction_id');
					 RETURN;
					 END IF;
      END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate parent_id in JTF_IH_PUB.Validate_Interaction_Record');
/*
   -- Validate descriptive flexfield values
   ----------------------------------------
   IF ((p_int_val_rec.attribute1 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute2 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute3 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute4 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute5 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute6 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute7 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute8 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute9 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute10 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute11 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute12 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute13 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute14 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute15 <> fnd_api.g_miss_char) OR
       (p_int_val_rec.attribute_category <> fnd_api.g_miss_char)) THEN
  jtf_ih_core_util_pvt.validate_desc_flex
  ( p_api_name      => p_api_name,
    p_desc_flex_name      => 'JTF_IH',
    p_column_name1  => 'ATTRIBUTE1',
    p_column_name2  => 'ATTRIBUTE2',
    p_column_name3  => 'ATTRIBUTE3',
    p_column_name4  => 'ATTRIBUTE4',
    p_column_name5  => 'ATTRIBUTE5',
    p_column_name6  => 'ATTRIBUTE6',
    p_column_name7  => 'ATTRIBUTE7',
    p_column_name8  => 'ATTRIBUTE8',
    p_column_name9  => 'ATTRIBUTE9',
    p_column_name10       => 'ATTRIBUTE10',
    p_column_name11       => 'ATTRIBUTE11',
    p_column_name12       => 'ATTRIBUTE12',
    p_column_name13       => 'ATTRIBUTE13',
    p_column_name14       => 'ATTRIBUTE14',
    p_column_name15       => 'ATTRIBUTE15',
    p_column_value1       => p_int_val_rec.attribute1,
    p_column_value2       => p_int_val_rec.attribute2,
    p_column_value3       => p_int_val_rec.attribute3,
    p_column_value4       => p_int_val_rec.attribute4,
    p_column_value5       => p_int_val_rec.attribute5,
    p_column_value6       => p_int_val_rec.attribute6,
    p_column_value7       => p_int_val_rec.attribute7,
    p_column_value8       => p_int_val_rec.attribute8,
    p_column_value9       => p_int_val_rec.attribute9,
    p_column_value10      => p_int_val_rec.attribute10,
    p_column_value11      => p_int_val_rec.attribute11,
    p_column_value12      => p_int_val_rec.attribute12,
    p_column_value13      => p_int_val_rec.attribute13,
    p_column_value14      => p_int_val_rec.attribute14,
    p_column_value15      => p_int_val_rec.attribute15,
    p_context_value       => p_int_val_rec.attribute_category,
    p_resp_appl_id  => p_resp_appl_id,
    p_resp_id       => p_resp_id,
    x_return_status       => x_return_status);
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
   RETURN;
      END IF;
   END IF;*/
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate flexfields in JTF_IH_PUB.Validate_Interaction_Record');
  END Validate_Interaction_Record;


  PROCEDURE Default_Interaction_Record  (x_interaction     IN OUT NOCOPY  interaction_rec_type);

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Default_Interaction_Record  (x_interaction     IN OUT NOCOPY  interaction_rec_type)
  IS
	BEGIN
		if (x_interaction.handler_id = fnd_api.g_miss_num)then
			x_interaction.handler_id :=0;
		end if;
			if (x_interaction.script_id = fnd_api.g_miss_num)then
			x_interaction.script_id :=0;
		end if;

		if (x_interaction.result_id = fnd_api.g_miss_num)then
			x_interaction.result_id :=0;
		end if;

		if (x_interaction.reason_id = fnd_api.g_miss_num)then
			x_interaction.reason_id :=0;
		end if;

		if (x_interaction.resource_id = fnd_api.g_miss_num)then
			x_interaction.resource_id :=0;
		end if;

		if (x_interaction.party_id = fnd_api.g_miss_num)then
			x_interaction.party_id :=0;
		end if;

		if (x_interaction.object_id = fnd_api.g_miss_num)then
			x_interaction.object_id :=0;
		end if;
		if (x_interaction.source_code_id = fnd_api.g_miss_num)then
			x_interaction.source_code_id :=0;
		end if;
	END;

  PROCEDURE Default_activity_table  (x_activities     IN OUT NOCOPY  activity_tbl_type);

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Default_activity_table  (x_activities     IN OUT NOCOPY  activity_tbl_type)
  IS
	BEGIN

		for  idx in 1 .. x_activities.count loop
			if (x_activities(idx).task_id = fnd_api.g_miss_num)then
				x_activities(idx).task_id :=0;
			end if;
			if (x_activities(idx).doc_id = fnd_api.g_miss_num)then
				x_activities(idx).doc_id :=0;
			end if;

			if (x_activities(idx).action_item_id = fnd_api.g_miss_num)then
				x_activities(idx).action_item_id :=0;
			end if;

			if (x_activities(idx).outcome_id = fnd_api.g_miss_num) then
				x_activities(idx).outcome_id :=0;
			end if;

			if (x_activities(idx).result_id = fnd_api.g_miss_num)then
				x_activities(idx).result_id :=0;
			end if;
			if (x_activities(idx).reason_id = fnd_api.g_miss_num)then
				x_activities(idx).reason_id :=0;
			end if;
			if (x_activities(idx).object_id = fnd_api.g_miss_num)then
				x_activities(idx).object_id :=0;
			end if;
			if (x_activities(idx).source_code_id = fnd_api.g_miss_num)then
				x_activities(idx).source_code_id:=0;
			end if;
		end loop;
  END;

--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	Jean Zhu	11-JAN-2000	INITIAL VERSION
--	James Baldo Jr.	06-MAR-2000	Implementation fix for Cust_Account_ID Bug
--	James Baldo Jr.	02-MAY-2000	Modified to validate AMS campaigns
--	James Baldo Jr.	27-JUL-2000	Implemenation fix for bugdb # 1340768
--  Igor Aleshin    03-JAN-2002 Implemenation fix for bugdb # 2167904
--

PROCEDURE Validate_Activity_Record
  ( p_api_name    IN      VARCHAR2,
    p_act_val_rec       IN      activity_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition

  PROCEDURE Validate_Activity_Record
  ( p_api_name    IN      VARCHAR2,
    p_act_val_rec       IN      activity_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  )
  IS
    l_count NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

  IF ((p_act_val_rec.interaction_id IS NOT NULL) AND (p_act_val_rec.interaction_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(interaction_id) into l_count
   FROM jtf_ih_interactions
   WHERE interaction_id = p_act_val_rec.interaction_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.interaction_id),
					    'interaction_id');
					 RETURN;
					 END IF;
       END;
   ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.interaction_id),
					    'interaction_id');
			 RETURN;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate interaction_id in JTF_IH_PUB.Validate_Activity_Record');

   l_count := 0;
   IF ((p_act_val_rec.action_item_id IS NOT NULL) AND (p_act_val_rec.action_item_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(action_item_id) into l_count
   FROM jtf_ih_action_items_b
   WHERE action_item_id = p_act_val_rec.action_item_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.action_item_id),
					    'action_item_id');
					 RETURN;
					 END IF;
       END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate action_item_id in JTF_IH_PUB.Validate_Activity_Record');

   l_count := 0;
   IF ((p_act_val_rec.outcome_id IS NOT NULL) AND (p_act_val_rec.outcome_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(outcome_id) into l_count
   FROM jtf_ih_outcomes_B
   WHERE outcome_id = p_act_val_rec.outcome_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.outcome_id),
					    'outcome_id');
					 RETURN;
					 END IF;

   	   END;
    END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate outcome_id in JTF_IH_PUB.Validate_Activity_Record');


   l_count := 0;
   IF ((p_act_val_rec.action_id IS NOT NULL) AND (p_act_val_rec.action_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(action_id) into l_count
   FROM jtf_ih_actions_b
   WHERE action_id = p_act_val_rec.action_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.action_id),
					    'action_id');
					 RETURN;
					 END IF;
      END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate action_id in JTF_IH_PUB.Validate_Activity_Record');
   l_count := 0;
   IF ((p_act_val_rec.result_id IS NOT NULL) AND (p_act_val_rec.result_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(result_id) into l_count
   FROM jtf_ih_results_B
   WHERE result_id = p_act_val_rec.result_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.result_id),
					    'result_id');
					 RETURN;
					 END IF;

       END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate result_id in JTF_IH_PUB.Validate_Activity_Record');

   l_count := 0;
   IF ((p_act_val_rec.reason_id IS NOT NULL) AND (p_act_val_rec.reason_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(reason_id) into l_count
   FROM jtf_ih_reasons_B
   WHERE reason_id = p_act_val_rec.reason_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.reason_id),
					    'reason_id');
					 RETURN;
					 END IF;
       END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate reason_id in JTF_IH_PUB.Validate_Activity_Record');



-- Validate AMS_Source_Code table primary key source_code_id for the following permutation:
--			source_code_id does have a value
--			source_code    does not have a value
--
	l_count := 0;
	IF ((p_act_val_rec.source_code_id IS NOT NULL) AND
		(p_act_val_rec.source_code_id <> fnd_api.g_miss_num)) AND
		((p_act_val_rec.source_code IS NULL) OR
		(p_act_val_rec.source_code = fnd_api.g_miss_char)) THEN
		BEGIN
			SELECT
				count(source_code_id) into l_count
			FROM
				ams_source_codes
			WHERE
				source_code_id = p_act_val_rec.source_code_id;
			IF (l_count <= 0) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.source_code_id), 'SOURCE_CODE_ID');
				RETURN;
			END IF;
      		END;
	END IF;


-- Validate AMS_Source_Code table primary key source_code_id for the following permutation:
--			source_code_id does not have a value
--			source_code    does  have a value
--
	l_count := 0;
	IF ((p_act_val_rec.source_code IS NOT NULL) AND
		(p_act_val_rec.source_code <> fnd_api.g_miss_char)) AND
		((p_act_val_rec.source_code_id IS NULL) OR
		(p_act_val_rec.source_code_id = fnd_api.g_miss_num)) THEN
		BEGIN
			SELECT
				count(source_code_id) into l_count
			FROM
				ams_source_codes
			WHERE
				source_code = p_act_val_rec.source_code;
			IF (l_count <= 0) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_act_val_rec.source_code, 'SOURCE_CODE');
				RETURN;
			END IF;
      		END;
	END IF;

-- Validate AMS_Source_Code table primary key source_code_id for the following permutation:
--			source_code_id does have a value
--			source_code    does  have a value
--
	l_count := 0;
	IF ((p_act_val_rec.source_code IS NOT NULL) AND
		(p_act_val_rec.source_code <> fnd_api.g_miss_char)) AND
		((p_act_val_rec.source_code_id IS NOT NULL) AND
		(p_act_val_rec.source_code_id <> fnd_api.g_miss_num)) THEN
		BEGIN
			SELECT
				count(source_code_id) into l_count
			FROM
				ams_source_codes
			WHERE
				source_code    = p_act_val_rec.source_code AND
				source_code_id = p_act_val_rec.source_code_id;
			IF (l_count <= 0) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_act_val_rec.source_code || '  ' || to_char(p_act_val_rec.source_code_id), 'SOURCE_CODE, SOURCE_CODE_ID');
				RETURN;
			END IF;
    END;
	END IF;


   -- DBMS_OUTPUT.PUT_LINE('PAST Validate source_code_id in JTF_IH_PUB.Validate_Activity_Record');

   l_count := 0;
   IF ((p_act_val_rec.cust_account_id IS NOT NULL) AND (p_act_val_rec.cust_account_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(cust_account_id) into l_count
   FROM hz_cust_accounts
   WHERE cust_account_id = p_act_val_rec.cust_account_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.cust_account_id),
					    'cust_account_id');
					 RETURN;
					 END IF;
      END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate cust_account_id in JTF_IH_PUB.Validate_Activity_Record');

   l_count := 0;
   IF ((p_act_val_rec.media_id IS NOT NULL) AND (p_act_val_rec.media_id <> fnd_api.g_miss_num)) THEN
   	   BEGIN
   	     SELECT count(media_id) into l_count
   FROM jtf_ih_media_items
   WHERE media_id = p_act_val_rec.media_id;
     IF (l_count <= 0) THEN
     x_return_status := fnd_api.g_ret_sts_error;
     jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_act_val_rec.media_id),
					    'media_id');
					 RETURN;
      END IF;
  END;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST Validate media_id in JTF_IH_PUB.Validate_Activity_Record');

  END Validate_Activity_Record;


  PROCEDURE Validate_Activity_table
  ( p_api_name    IN      VARCHAR2,
    p_int_val_tbl       IN      activity_tbl_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Validate_Activity_table
  ( p_api_name    IN      VARCHAR2,
    p_int_val_tbl       IN      activity_tbl_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  )

  IS
  l_count NUMBER := 0;

  BEGIN
    -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

  -- Modified to call Validate_Activity_Record
	for  idx in 1 .. p_int_val_tbl.count loop
		Validate_Activity_Record(p_api_name, p_int_val_tbl(idx),p_resp_appl_id,p_resp_id,x_return_status);
		IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      		---- DBMS_OUTPUT.PUT_LINE('Unsuccessful validation of a activity record in jtf_ih_pub.Validate_Activity_table');
			RETURN;
		END IF;
	END loop;
  END Validate_Activity_table;
PROCEDURE Validate_Media_Item
  ( p_api_name    IN      VARCHAR2,
    p_media_item_val    IN      media_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  );

--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	James Baldo	11-JAN-2000	INITIAL VERSION
--	James Baldo Jr.	06-MAR-2000	Fix for Source_ID Bugdb 1317098 and 1316836
--
  PROCEDURE Validate_Media_Item
  ( p_api_name    IN      VARCHAR2,
    p_media_item_val    IN      media_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  )

  IS
  l_count NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
  x_return_status := fnd_api.g_ret_sts_success;


--  IF ((p_media_item_val.source_id IS NOT NULL) AND (p_media_item_val.source_id <> fnd_api.g_miss_num)) THEN
--   	 SELECT count(*) into l_count
--   FROM jtf_ih_sources
--   WHERE source_id = p_media_item_val.source_id;
--     IF (l_count <= 0) THEN
--   	 x_return_status := fnd_api.g_ret_sts_error;
--     	jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_item_val.source_id),
--					    'Source_id');
--		RETURN;
--	   END IF;
-- ELSE
-- 	x_return_status := fnd_api.g_ret_sts_error;
--  jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_item_val.source_id),
--					    'Source_id');
--	RETURN;
-- END IF;

   IF ((p_media_item_val.media_item_type IS  NULL) OR (p_media_item_val.media_item_type = fnd_api.g_miss_char)) THEN
   	   x_return_status := fnd_api.g_ret_sts_error;
	   jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_media_item_val.media_item_type,
					    'media_item_type');
	   RETURN;
   END IF;

  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RETURN;
      END IF;
  END Validate_Media_Item;

  PROCEDURE Default_Media_Item_Record  (x_media     IN OUT NOCOPY  media_rec_type);

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Default_Media_Item_Record  (x_media     IN OUT NOCOPY  media_rec_type)
  IS
	BEGIN
		if (x_media.source_id = fnd_api.g_miss_num)then
			x_media.source_id :=0;
		end if;
		if (x_media.source_item_id = fnd_api.g_miss_num)then
			x_media.source_item_id :=0;
		end if;
	END Default_Media_Item_Record;

-- Jean Zhu add Utility Validate_Mlcs_Record
  PROCEDURE Validate_Mlcs_Record
  ( p_api_name    IN      VARCHAR2,
    p_media_lc_rec      IN      media_lc_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition
--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	James Baldo Jr.	11-JAN-2000	INITIAL VERSION
--	James Baldo Jr.	01-JUN-2000	Fix for bugdb 1314786 - optional parameter for passing either
--					milcs_type_id or milcs_code
--	James Baldo Jr. 26-JUL-2000	Fix for bugdb 1314821 and 1342156
--
  PROCEDURE Validate_Mlcs_Record
  ( p_api_name    IN      VARCHAR2,
    p_media_lc_rec      IN      media_lc_rec_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  )

  IS
  l_count 		NUMBER := 0;

  BEGIN
    -- Initialize API return status to success
	x_return_status := fnd_api.g_ret_sts_success;
   l_count := 0;
      	-- DBMS_OUTPUT.PUT_LINE('Beginning validation of a media_lc record in jtf_ih_pub.Validate_Mlcs_Record');

  IF (((p_media_lc_rec.milcs_type_id IS NULL) OR (p_media_lc_rec.milcs_type_id = fnd_api.g_miss_num))
	AND
	((p_media_lc_rec.milcs_code IS NULL) OR (p_media_lc_rec.milcs_code = fnd_api.g_miss_char))) THEN
  	   x_return_status := fnd_api.g_ret_sts_error;
	jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, 'NULL or Missing',
					    'milcs_code');
  jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, 'Null or Missing',
					    'milcs_type_id');
	RETURN;
  END IF;
  IF ((p_media_lc_rec.milcs_type_id IS NOT NULL) AND (p_media_lc_rec.milcs_type_id <> fnd_api.g_miss_num)
	AND
	(p_media_lc_rec.milcs_code IS NOT NULL) AND (p_media_lc_rec.milcs_code <> fnd_api.g_miss_char)) THEN
	SELECT count(milcs_type_id) into l_count
	FROM jtf_ih_media_itm_lc_seg_tys
	WHERE milcs_type_id = p_media_lc_rec.milcs_type_id;
	IF (l_count <= 0) THEN
		x_return_status := fnd_api.g_ret_sts_error;
		jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_media_lc_rec.milcs_type_id,
							 'milcs_type_id');
	END IF;
	SELECT count(milcs_type_id) into l_count
	FROM jtf_ih_media_itm_lc_seg_tys
	WHERE milcs_code = p_media_lc_rec.milcs_code;
	IF (l_count <= 0) THEN
		x_return_status := fnd_api.g_ret_sts_error;
	jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_media_lc_rec.milcs_code,
							  'milcs_code');
	END IF;
	IF  x_return_status = fnd_api.g_ret_sts_error THEN
		RETURN;
	END IF;
  END IF;
  IF (((p_media_lc_rec.milcs_type_id IS NOT NULL) AND (p_media_lc_rec.milcs_type_id <> fnd_api.g_miss_num)) AND
      ((p_media_lc_rec.milcs_code IS NULL) OR (p_media_lc_rec.milcs_code = fnd_api.g_miss_char))) THEN
	SELECT count(milcs_type_id) into l_count
	FROM jtf_ih_media_itm_lc_seg_tys
	WHERE milcs_type_id = p_media_lc_rec.milcs_type_id;
		IF (l_count <= 0) THEN
			x_return_status := fnd_api.g_ret_sts_error;
			jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_media_lc_rec.milcs_type_id,
							    'milcs_type_id');
			RETURN;
		END IF;
  END IF;
  IF ((p_media_lc_rec.milcs_code IS NOT NULL) AND (p_media_lc_rec.milcs_code <> fnd_api.g_miss_char)) THEN
	SELECT count(milcs_type_id) into l_count
	FROM jtf_ih_media_itm_lc_seg_tys
	WHERE milcs_code = p_media_lc_rec.milcs_code;
		IF (l_count <= 0) THEN
			x_return_status := fnd_api.g_ret_sts_error;
			jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_media_lc_rec.milcs_code,
							    'milcs_code');
			RETURN;
		END IF;
  END IF;
  l_count := 0;
  IF ((p_media_lc_rec.handler_id IS NOT NULL) AND (p_media_lc_rec.handler_id <> fnd_api.g_miss_num)) THEN
		SELECT count(application_id) into l_count
		FROM fnd_application
		WHERE application_id = p_media_lc_rec.handler_id;
			IF (l_count <= 0) THEN
			x_return_status := fnd_api.g_ret_sts_error;
			jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, p_media_lc_rec.handler_id,
							    'handler_id');
			RETURN;
			END IF;
   ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_lc_rec.handler_id),
					    'handler_id');
			 RETURN;
  END IF;
  l_count := 0;
  IF ((p_media_lc_rec.media_id IS NOT NULL) AND (p_media_lc_rec.media_id <> fnd_api.g_miss_num)) THEN
		SELECT count(media_id) into l_count
		FROM jtf_ih_media_items
		WHERE media_id = p_media_lc_rec.media_id;
			IF (l_count <= 0) THEN
			x_return_status := fnd_api.g_ret_sts_error;
			jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_lc_rec.media_id),
							    'media_id');
			RETURN;
			END IF;
/*   ELSE
   	   x_return_status := fnd_api.g_ret_sts_error;
       jtf_ih_core_util_pvt.add_invalid_argument_msg(p_api_name, to_char(p_media_lc_rec.handler_id),
					    'handler_id');
			 RETURN;*/
  END IF;
   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
   		RETURN;
   END IF;
  END Validate_Mlcs_Record;

  PROCEDURE Validate_Mlcs_table
  ( p_api_name    IN      VARCHAR2,
    p_mlcs_val_tab       IN      mlcs_tbl_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  );

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Validate_Mlcs_table
  ( p_api_name    IN      VARCHAR2,
    p_mlcs_val_tab       IN      mlcs_tbl_type,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id     IN      NUMBER   := NULL,
    x_return_status     IN OUT NOCOPY  VARCHAR2
  )

  IS
  l_count NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_count := 0;

	 for  idx in 1 .. p_mlcs_val_tab.count loop
	 	  Validate_Mlcs_Record  ( p_api_name, p_mlcs_val_tab(idx), p_resp_appl_id, p_resp_id, x_return_status);
   END loop;

   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      	-- DBMS_OUTPUT.PUT_LINE('Unsuccessful validation of a media_lc record in jtf_ih_pub.Validate_Mlcs_table');
    	RETURN;
   END IF;
  END Validate_Mlcs_table;

  PROCEDURE Default_Mlcs_table  (x_mlcs     IN OUT NOCOPY  mlcs_tbl_type);

--  End Utilities Declaration
-- Begin Utilities Definition
  PROCEDURE Default_Mlcs_table  (x_mlcs     IN OUT NOCOPY  mlcs_tbl_type)
  IS
	BEGIN
		for  idx in 1 .. x_mlcs.count loop
			if (x_mlcs(idx).type_id = fnd_api.g_miss_num)then
				x_mlcs(idx).type_id :=0;
			end if;
			if (x_mlcs(idx).handler_id = fnd_api.g_miss_num)then
				x_mlcs(idx).handler_id :=0;
			end if;
		end loop;
	END Default_Mlcs_table;


-- Bug# 2817083
-- HISTORY
--
--	AUTHOR		     DATE		MODIFICATION DESCRIPTION
--	------		     ----		--------------------------
--  Igor Aleshin     02/24/2003  Created
--
FUNCTION Get_Activity_ID(n_activity_id NUMBER) RETURN NUMBER
IS
    n_Return NUMBER;
    n_Dummy NUMBER;
BEGIN
  -- if b_Ignore_Pass is 'Y' then always generate a new ID
  IF (n_activity_id IS NOT NULL) AND (n_activity_id <> fnd_api.g_miss_num) THEN
      -- Check activity value in the JTF_IH_ACTIVITIES table.
      BEGIN
    SELECT activity_id INTO n_Return FROM jtf_ih_activities WHERE activity_id = n_activity_id;
      -- If value is presend then return an error (invalid activity_id)
      IF n_Return IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('JTF','JTF_IH_API_INVALID_ACTIV_ID');
          fnd_message.set_token('VALUE', n_activity_id);
          FND_MSG_PUB.Add;
          RETURN -1;
      END IF;
      EXCEPTION
      -- If value is not presend then use it for currect activity.
      WHEN NO_DATA_FOUND THEN
          RETURN n_activity_id;
      END;
  ELSIF ((n_activity_id IS NULL) OR (n_activity_id = fnd_api.g_miss_num)) THEN
         LOOP
      SELECT jtf_ih_activities_s1.NEXTVAL INTO n_Return FROM dual;
      BEGIN
          SELECT activity_id INTO n_Dummy FROM jtf_ih_activities WHERE activity_id = n_Return;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
        EXIT;
      END;
         END LOOP;
         RETURN n_Return;
         -- If value is not present then accept it for current record.
  END IF;
END;


-- HISTORY
--
--	AUTHOR		     DATE		MODIFICATION DESCRIPTION
--	------		     ----		--------------------------
--  Igor Aleshin     02/24/2003  Created
--
FUNCTION Get_Interaction_ID(n_interaction_id NUMBER) RETURN NUMBER
IS
    n_Return NUMBER;
    n_Dummy NUMBER;
BEGIN
  IF (n_interaction_id IS NOT NULL) AND (n_interaction_id <> fnd_api.g_miss_num) THEN
      -- Check activity value in the JTF_IH_ACTIVITIES table.
      BEGIN
    SELECT interaction_id INTO n_Return FROM jtf_ih_interactions WHERE interaction_id = n_interaction_id;
      -- If value is presend then return an error (invalid activity_id)
      IF n_Return IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('JTF','JTF_IH_API_INVALID_INTER_ID');
          FND_MESSAGE.SET_TOKEN('VALUE', n_interaction_id);
          FND_MSG_PUB.Add;
          RETURN -1;
      END IF;
      EXCEPTION
      -- If value is not presend then use it for currect activity.
      WHEN NO_DATA_FOUND THEN
          RETURN n_interaction_id;
      END;
  ELSIF ((n_interaction_id IS NULL) OR (n_interaction_id = fnd_api.g_miss_num)) THEN
         LOOP
      SELECT jtf_ih_interactions_s1.NEXTVAL INTO n_Return FROM dual;
      BEGIN
          SELECT interaction_id INTO n_Dummy FROM jtf_ih_interactions WHERE interaction_id = n_Return;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
        EXIT;
      END;
         END LOOP;
         RETURN n_Return;
         -- If value is not present then accept it for current record.
  END IF;
END;

-- HISTORY
--
--	AUTHOR		     DATE		MODIFICATION DESCRIPTION
--	------		     ----		--------------------------
--  Igor Aleshin     02/24/2003  Created
--
FUNCTION Get_Media_ID(n_media_id NUMBER) RETURN NUMBER
IS
    n_Return NUMBER;
    n_Dummy NUMBER;
BEGIN
  IF (n_media_id IS NOT NULL) AND (n_media_id <> fnd_api.g_miss_num) THEN
      -- Check activity value in the JTF_IH_ACTIVITIES table.
      BEGIN
    SELECT media_id INTO n_Return FROM jtf_ih_media_items WHERE media_id = n_media_id;
      -- If value is presend then return an error (invalid activity_id)
      IF n_Return IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('JTF','JTF_IH_API_INVALID_MEDIA_ID');
          FND_MESSAGE.SET_TOKEN('VALUE', n_media_id);
          FND_MSG_PUB.Add;
          RETURN -1;
      END IF;
      EXCEPTION
      -- If value is not presend then use it for currect activity.
      WHEN NO_DATA_FOUND THEN
          RETURN n_media_id;
      END;
  ELSIF ((n_media_id IS NULL) OR (n_media_id = fnd_api.g_miss_num)) THEN
         LOOP
      SELECT jtf_ih_media_items_s1.NEXTVAL INTO n_Return FROM dual;
      BEGIN
          SELECT n_media_id INTO n_Dummy FROM jtf_ih_media_items WHERE media_id = n_Return;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
        EXIT;
      END;
         END LOOP;
         RETURN n_Return;
         -- If value is not present then accept it for current record.
  END IF;
END;


-- HISTORY
--
--	AUTHOR		     DATE		MODIFICATION DESCRIPTION
--	------		     ----		--------------------------
--  Igor Aleshin     02/24/2003  Created
--
FUNCTION GET_MILCS_ID(n_milcs_id NUMBER) RETURN NUMBER
IS
    n_Return NUMBER;
    n_Dummy NUMBER;
BEGIN
  IF (n_milcs_id IS NOT NULL) AND (n_milcs_id <> fnd_api.g_miss_num) THEN
      -- Check activity value in the JTF_IH_ACTIVITIES table.
      BEGIN
    SELECT milcs_id INTO n_Return FROM jtf_ih_media_item_lc_segs WHERE milcs_id = n_milcs_id;
      -- If value is presend then return an error (invalid activity_id)
      IF n_Return IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('JTF','JTF_IH_API_INVALID_MILCS_ID');
          FND_MESSAGE.SET_TOKEN('VALUE', n_milcs_id);
          FND_MSG_PUB.Add;
          RETURN -1;
      END IF;
      EXCEPTION
      -- If value is not presend then use it for currect activity.
      WHEN NO_DATA_FOUND THEN
          RETURN n_milcs_id;
      END;
  ELSIF ((n_milcs_id IS NULL) OR (n_milcs_id = fnd_api.g_miss_num)) THEN
         LOOP
      SELECT jtf_ih_media_item_lc_seg_s1.NEXTVAL INTO n_Return FROM dual;
      BEGIN
          SELECT n_milcs_id INTO n_Dummy FROM jtf_ih_media_item_lc_segs WHERE milcs_id = n_Return;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
        EXIT;
      END;
         END LOOP;
         RETURN n_Return;
         -- If value is not present then accept it for current record.
  END IF;
END;

--
-- old version
--
--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--					INITIAL VERSION
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--	James Baldo Jr. 09-JUN-2000	Modified by for bug# 1326022
--  Igor Aleshin    18-APR-2001 Fix for bugdb 2323210 - 1157.6RI:API
--            ERR:JTF_IH_PUB.CLOSE_INTERACTION:WHEN DISAGREE WITH OKC IN IBE
--  Igor Aleshin    20-MAY-2002 Changed piece of code for duration logic
--  Igor Aleshin    24-FEB-2003 Fixed bug# 2817083 - Error loggin interactions
--  Igor Aleshin    29-MAY-2003 Enh# 2940473 - IH Bulk API Changes
--  Igor Aleshin    18-JUN-2003 Enh# 1846960 - REQUIRE CONTACT NAME OF
--                  ORGANISATION IN INTERACTION HISTORY
--  Igor Aleshin    01-JUL-2003 Added to missed columns to insert statments
--  Igor Aleshin    03-JUL-2003 Enh# 3022511 - Add a column to the
--                              jtf_ih_media_items table
--  vekrishn        27-JUL-2004 Perf Fix for literal Usage
--

PROCEDURE Create_MediaItem
(
  p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
  p_commit			IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
  p_resp_appl_id		IN	NUMBER   DEFAULT NULL,
  p_resp_id			IN	NUMBER   DEFAULT NULL,
  p_user_id			IN	NUMBER,
  p_login_id			IN	NUMBER   DEFAULT NULL,
  x_return_status		OUT NOCOPY	VARCHAR2,
  x_msg_count			OUT NOCOPY	NUMBER,
  x_msg_data			OUT NOCOPY	VARCHAR2,
  p_media 			IN media_rec_type,
  p_mlcs 			IN mlcs_tbl_type
  ) AS
  l_api_name   CONSTANT VARCHAR2(30) := 'Create_MediaItem';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
  l_return_status    VARCHAR2(1);
  l_int_val_rec      media_rec_type;
  l_milcs_id     NUMBER;
  l_mlcs mlcs_tbl_type;

  --Bug# 2323210
  l_start_date_time DATE;
  l_end_date_time DATE;
  l_duration     NUMBER;

  -- Perf fix for literal Usage
  l_duration_perf          NUMBER;
  l_active_perf            VARCHAR2(1);
  l_ao_update_pending_perf VARCHAR2(1);
  l_soft_closed_perf       VARCHAR2(1);

BEGIN

   -- local variables initialization to remove GSCC warnings
   l_int_val_rec := p_media;
   l_mlcs := p_mlcs;

   -- Perf variables
   l_duration_perf := 0;
   l_active_perf := 'N';
   l_ao_update_pending_perf := 'N';
   l_soft_closed_perf := 'N';

   -- Standard start of API savepoint
   SAVEPOINT create_media_pub;

   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   --
   -- Validate user and login session IDs
   --
   IF (p_user_id IS NULL) THEN
      jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
      RAISE fnd_api.g_exc_error;
   ELSE
      jtf_ih_core_util_pvt.validate_who_info
      ( p_api_name        => l_api_name_full,
        p_parameter_name_usr    => 'p_user_id',
        p_parameter_name_log    => 'p_login_id',
        p_user_id         => p_user_id,
        p_login_id        => p_login_id,
        x_return_status   => l_return_status );
      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   Validate_Media_Item
   ( p_api_name      => l_api_name_full,
     p_media_item_val      => p_media,
     p_resp_appl_id  => p_resp_appl_id,
     p_resp_id       => p_resp_id,
     x_return_status       => l_return_status
   );
   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
     RAISE fnd_api.g_exc_error;
   END IF;
   Default_Media_Item_Record(l_int_val_rec);

   IF (p_media.end_date_time <> fnd_api.g_miss_date) AND
      (p_media.end_date_time IS NOT NULL) THEN
      l_int_val_rec.end_date_time := p_media.end_date_time;
   ELSE
      l_int_val_rec.end_date_time := SYSDATE;
   END IF;

   IF (p_media.start_date_time <> fnd_api.g_miss_date) AND
      (p_media.start_date_time IS NOT NULL) THEN
      l_int_val_rec.start_date_time := p_media.start_date_time;
   ELSE
      l_int_val_rec.start_date_time := SYSDATE;
   END IF;

   Validate_StartEnd_Date(	p_api_name    => l_api_name_full,
      p_start_date_time   => l_int_val_rec.start_date_time,
      p_end_date_time		=> l_int_val_rec.end_date_time,
      x_return_status     	=> l_return_status);
   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

    IF (p_media.source_item_create_date_time <> fnd_api.g_miss_date) AND
       (p_media.source_item_create_date_time IS NOT NULL) THEN
      l_int_val_rec.source_item_create_date_time := p_media.source_item_create_date_time;
    ELSE
      l_int_val_rec.source_item_create_date_time := NULL;
    END IF;

    IF (p_media.duration <> fnd_api.g_miss_num) AND
       (p_media.duration IS NOT NULL) then
      l_int_val_rec.duration := p_media.duration;
    ELSE
      l_int_val_rec.duration := ROUND((l_int_val_rec.end_date_time - l_int_val_rec.start_date_time)*24*60*60);
    END IF;

    IF p_media.address = fnd_api.g_miss_char THEN
       IF l_int_val_rec.direction = 'INBOUND' AND l_int_val_rec.media_item_type like 'TELE%' THEN
          l_int_val_rec.address := l_int_val_rec.ani;
       ELSE
          l_int_val_rec.address := NULL;
       END IF;
    ELSE
       l_int_val_rec.address := p_media.address;
    END IF;

    --IF ((p_media.media_id IS NULL) OR (p_media.media_id = fnd_api.g_miss_num)) THEN
    --    SELECT jtf_ih_media_items_s1.NEXTVAL INTO l_int_val_rec.media_id FROM dual;
    --END IF;
    -- Bug# 2817083
    l_int_val_rec.media_id := Get_Media_Id(p_media.media_id);
    IF l_int_val_rec.media_id = -1 THEN
       RAISE fnd_api.g_exc_error;
    END IF;

    -- Perf fix for literal Usage
    insert into jtf_ih_Media_Items
    (
        DURATION,
        DIRECTION,
        END_DATE_TIME,
        SOURCE_ITEM_CREATE_DATE_TIME,
        INTERACTION_PERFORMED,
        SOURCE_ITEM_ID,
        START_DATE_TIME,
        MEDIA_ID,
        SOURCE_ID,
        MEDIA_ITEM_TYPE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        MEDIA_ITEM_REF,
        MEDIA_DATA,
        ACTIVE,
        SERVER_GROUP_ID,
        DNIS,
        ANI,
        CLASSIFICATION,
        BULK_WRITER_CODE,
        BULK_BATCH_TYPE,
        BULK_BATCH_ID,
        BULK_INTERACTION_ID,
        media_abandon_flag,
        media_transferred_flag,
        address,
        ao_update_pending,
        soft_closed
    ) values (
        decode( l_int_val_rec.duration, fnd_api.g_miss_num, l_duration_perf, l_int_val_rec.duration),
        decode( l_int_val_rec.direction, fnd_api.g_miss_char, null, l_int_val_rec.direction),
        l_int_val_rec.end_date_time,
        l_int_val_rec.source_item_create_date_time,
        decode( l_int_val_rec.interaction_performed, fnd_api.g_miss_char, null, l_int_val_rec.interaction_performed),
        decode( l_int_val_rec.source_item_id, fnd_api.g_miss_num, null, l_int_val_rec.source_item_id),
        -- Bug # 2184405
        l_int_val_rec.start_date_time,
        l_int_val_rec.media_id,
        decode( l_int_val_rec.source_id, fnd_api.g_miss_num, null, l_int_val_rec.source_id),
        decode( l_int_val_rec.media_item_type, fnd_api.g_miss_char, null, l_int_val_rec.media_item_type),
        p_user_id,
        SysDate,
        p_user_id,
        SysDate,
        p_login_id,
        decode( l_int_val_rec.media_item_ref, fnd_api.g_miss_char, null, l_int_val_rec.media_item_ref),
        decode( l_int_val_rec.media_data, fnd_api.g_miss_char, null, l_int_val_rec.media_data),
        l_active_perf,
        decode( l_int_val_rec.server_group_id, fnd_api.g_miss_num, null, l_int_val_rec.server_group_id),
        decode( l_int_val_rec.dnis, fnd_api.g_miss_char, null, l_int_val_rec.dnis),
        decode( l_int_val_rec.ani, fnd_api.g_miss_char, null, l_int_val_rec.ani),
        decode( l_int_val_rec.classification, fnd_api.g_miss_char, null, l_int_val_rec.classification),
        decode( l_int_val_rec.bulk_writer_code, fnd_api.g_miss_char, null, l_int_val_rec.bulk_writer_code),
        decode( l_int_val_rec.bulk_batch_type, fnd_api.g_miss_char, null, l_int_val_rec.bulk_batch_type),
        decode( l_int_val_rec.bulk_batch_id, fnd_api.g_miss_num, null, l_int_val_rec.bulk_batch_id),
        decode( l_int_val_rec.bulk_interaction_id, fnd_api.g_miss_num, null, l_int_val_rec.bulk_interaction_id),
        decode( l_int_val_rec.media_abandon_flag, fnd_api.g_miss_char, null, l_int_val_rec.media_abandon_flag),
        decode( l_int_val_rec.media_transferred_flag, fnd_api.g_miss_char, null, l_int_val_rec.media_transferred_flag),
        decode( l_int_val_rec.address, fnd_api.g_miss_char, null, l_int_val_rec.address),
        l_ao_update_pending_perf,
        l_soft_closed_perf
    );

    -- Added by IAleshin 20-MAY-2002
    -- Fill new Media_ID for child MediaLifeCycle
    for  idx in 1 .. l_mlcs.count loop
       l_mlcs(idx).media_id := l_int_val_rec.media_id;
    end loop;

    Validate_Mlcs_table
    (   p_api_name      => l_api_name_full,
        p_mlcs_val_tab   => l_mlcs,
        p_resp_appl_id  => p_resp_appl_id,
        p_resp_id       => p_resp_id,
        x_return_status       => l_return_status
    );
    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
       RAISE fnd_api.g_exc_error;
    END IF;

    Default_Mlcs_table(l_mlcs);

    for  idx in 1 .. p_mlcs.count loop
        IF (p_mlcs(idx).end_date_time <> fnd_api.g_miss_date) AND
           (p_mlcs(idx).end_date_time IS NOT NULL) THEN
            l_mlcs(idx).end_date_time := p_mlcs(idx).end_date_time;
        ELSE
            l_mlcs(idx).end_date_time := SYSDATE;
        END IF;

        IF (p_mlcs(idx).start_date_time <> fnd_api.g_miss_date) AND
           (p_mlcs(idx).start_date_time IS NOT NULL) THEN
            l_mlcs(idx).start_date_time := p_mlcs(idx).start_date_time;
        ELSE
            l_mlcs(idx).start_date_time := SYSDATE;
        END IF;

        Validate_StartEnd_Date(	p_api_name    => l_api_name_full,
           p_start_date_time   	=> l_mlcs(idx).start_date_time,
           p_end_date_time		=> l_mlcs(idx).end_date_time,
           x_return_status     	=> l_return_status
        );
        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
           RAISE fnd_api.g_exc_error;
        END IF;

        IF (p_mlcs(idx).duration <> fnd_api.g_miss_num) AND
           (p_mlcs(idx).duration IS NOT NULL) THEN
           l_mlcs(idx).duration := p_mlcs(idx).duration;
        ELSE
           l_mlcs(idx).duration := ROUND((l_mlcs(idx).end_date_time - l_mlcs(idx).start_date_time)*24*60*60);
        END IF;

        --IF ((p_mlcs(idx).milcs_id IS NULL) OR (p_mlcs(idx).milcs_id = fnd_api.g_miss_num)) THEN
        --    SELECT jtf_ih_media_item_lc_seg_s1.NEXTVAL INTO l_mlcs(idx).milcs_id FROM dual;
        --END IF;

        -- Bug# 2817083
        l_mlcs(idx).milcs_id := Get_milcs_id(p_mlcs(idx).milcs_id);
        IF l_mlcs(idx).milcs_id = -1 THEN
           RAISE fnd_api.g_exc_error;
        END IF;

        -- Perf fix for literal Usage
        insert into jtf_ih_media_item_lc_segs
        (
           START_DATE_TIME,
           TYPE_TYPE,
           TYPE_ID,
           DURATION,
           END_DATE_TIME,
           MILCS_ID,
           MILCS_TYPE_ID,
           MEDIA_ID,
           HANDLER_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTIVE,
           BULK_WRITER_CODE,
           BULK_BATCH_TYPE,
           BULK_BATCH_ID,
           BULK_INTERACTION_ID,
           RESOURCE_ID
        )
        values
        (
           l_mlcs(idx).start_date_time,
           decode( l_mlcs(idx).type_type, fnd_api.g_miss_char, null, l_mlcs(idx).type_type),
           decode( l_mlcs(idx).type_id, fnd_api.g_miss_num, null, l_mlcs(idx).type_id),
           decode( l_mlcs(idx).duration, fnd_api.g_miss_num, l_duration_perf, l_mlcs(idx).duration),
           l_mlcs(idx).end_date_time,
           l_mlcs(idx).milcs_id,
           decode( l_mlcs(idx).milcs_type_id, fnd_api.g_miss_num, null, l_mlcs(idx).milcs_type_id),
           l_int_val_rec.media_id,
           l_mlcs(idx).handler_id,
           p_user_id,
           Sysdate,
           p_user_id,
           Sysdate,
           p_login_id,
           l_active_perf,
           decode( l_mlcs(idx).bulk_writer_code, fnd_api.g_miss_char, null, l_mlcs(idx).bulk_writer_code),
           decode( l_mlcs(idx).bulk_batch_type, fnd_api.g_miss_char, null, l_mlcs(idx).bulk_batch_type),
           decode( l_mlcs(idx).bulk_batch_id, fnd_api.g_miss_num, null, l_mlcs(idx).bulk_batch_id),
           decode( l_mlcs(idx).bulk_interaction_id, fnd_api.g_miss_num, null, l_mlcs(idx).bulk_interaction_id),
           decode( l_mlcs(idx).resource_id, fnd_api.g_miss_num, null, l_mlcs(idx).resource_id)
           );
   END loop;


   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
       ( p_count       => x_msg_count,
         p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
       ( p_count       => x_msg_count,
         p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');

   WHEN OTHERS THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
       ( p_count       => x_msg_count,
         p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');

END Create_MediaItem;

--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--					INITIAL VERSION
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--	James Baldo Jr. 09-JUN-2000	Modified by for bug# 1326022
--	James Baldo Jr. 30-NOV-2000	Logic for two new columns, Media_Abandon_Flag and Media_Transferred_Flag.
--					Enhancement Bugdb # 1501325

--
-- Jean Zhu split old version PROCEDURE Create_MediaItem() to
-- two PROCEDUREs Create_MediaItem() and Create_MediaLifecycle()
--  Igor Aleshin    18-APR-2001 Fix for bugdb 2323210 - 1157.6RI:API
--            ERR:JTF_IH_PUB.CLOSE_INTERACTION:WHEN DISAGREE WITH OKC IN IBE
--  Igor Aleshin    24-FEB-2003 Fixed bug# 2817083 - Error loggin interactions
--  Igor Aleshin    29-MAY-2003 Enh# 2940473 - IH Bulk API Changes
--  Igor Aleshin    03-JUL-2003 Enh# 3022511 - Add a column to the jtf_ih_media_items table
--  vekrishn        27-JUL-2004 Perf Fix for literal Usage
--
--


PROCEDURE Create_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id		IN	NUMBER		DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_media_rec		IN	media_rec_type,
	x_media_id		OUT NOCOPY 	NUMBER
)AS

	l_api_name   	CONSTANT VARCHAR2(30) := 'Create_MediaItem';
	l_api_version      	CONSTANT NUMBER       := 1.0;
	l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
	l_return_status    	VARCHAR2(1);
	--l_media_id   	NUMBER := NULL;
	l_return_code		VARCHAR2(1);
	l_data			VARCHAR2(2000);
	l_count			NUMBER;
	l_media_rec		MEDIA_REC_TYPE;

     --Bug# 2323210
     --l_start_date_time DATE;
     --l_end_date_time DATE;
     --l_duration     NUMBER;
     --l_source_item_create_date_time DATE;
     --l_address VARCHAR2(2000);

    -- Perf fix for literal Usage
  l_duration_perf          NUMBER;
  l_active_perf            VARCHAR2(1);
  l_ao_update_pending_perf VARCHAR2(1);
  l_soft_closed_perf       VARCHAR2(1);

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT create_media_pub;

   -- Perf variables
   l_duration_perf := 0;
   l_active_perf := 'N';
   l_ao_update_pending_perf := 'N';
   l_soft_closed_perf := 'N';

			-- Preprocessing Call
			l_media_rec := p_media_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_MEDIAITEM', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.create_mediaitem_pre(
						     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_MEDIAITEM', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.create_mediaitem_pre(
						     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

	-- Standard call to check for call compatibility
	IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
	END IF;
	-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Create_MediaItem');

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := fnd_api.g_ret_sts_success;

	--
	-- Validate user and login session IDs
	--
	IF (p_user_id IS NULL) THEN
		jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
		RAISE fnd_api.g_exc_error;
	ELSE
		jtf_ih_core_util_pvt.validate_who_info
		(	p_api_name        => l_api_name_full,
			p_parameter_name_usr    => 'p_user_id',
			p_parameter_name_log    => 'p_login_id',
			p_user_id         => p_user_id,
			p_login_id        => p_login_id,
			x_return_status   => l_return_status );
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
	END IF;
	-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Create_MediaItem');

	Validate_Media_Item
	(	p_api_name      => l_api_name_full,
		p_media_item_val      => p_media_rec,
		p_resp_appl_id  => p_resp_appl_id,
		p_resp_id       => p_resp_id,
		x_return_status       => l_return_status
		);
	IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
	END IF;

	-- DBMS_OUTPUT.PUT_LINE('PAST Validate_Media_Item in JTF_IH_PUB.Create_MediaItem');

    -- Added by IAleshin 21-MAY-2002
    IF (p_media_rec.end_date_time <> fnd_api.g_miss_date) AND (p_media_rec.end_date_time IS NOT NULL) THEN
      --l_end_date_time := p_media_rec.end_date_time;
      l_media_rec.end_date_time := p_media_rec.end_date_time;
    ELSE
      --l_end_date_time := SYSDATE;
      l_media_rec.end_date_time := SYSDATE;
    END IF;

    IF (p_media_rec.start_date_time <> fnd_api.g_miss_date) AND (p_media_rec.start_date_time IS NOT NULL) THEN
      --l_start_date_time := p_media_rec.start_date_time;
      l_media_rec.start_date_time := p_media_rec.start_date_time;
    ELSE
      --l_start_date_time := SYSDATE;
      l_media_rec.start_date_time := SYSDATE;
    END IF;

    Validate_StartEnd_Date(	p_api_name    => l_api_name_full,
          --p_start_date_time   => l_start_date_time,
          p_start_date_time     => l_media_rec.start_date_time,
          --p_end_date_time		=> l_end_date_time,
          p_end_date_time	  => l_media_rec.end_date_time,
          x_return_status     => l_return_status);
  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
  END IF;

    IF (p_media_rec.source_item_create_date_time <> fnd_api.g_miss_date) AND (p_media_rec.source_item_create_date_time IS NOT NULL) THEN
      --l_source_item_create_date_time := p_media_rec.source_item_create_date_time;
      l_media_rec.source_item_create_date_time := p_media_rec.source_item_create_date_time;
    ELSE
      --l_source_item_create_date_time := NULL;
      l_media_rec.source_item_create_date_time := NULL;
    END IF;

    IF (p_media_rec.duration <> fnd_api.g_miss_num ) AND (p_media_rec.duration IS NOT NULL) THEN
      --l_duration := p_media_rec.duration;
      l_media_rec.duration := p_media_rec.duration;
    ELSE
      --l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
      l_media_rec.duration := ROUND((l_media_rec.end_date_time - l_media_rec.start_date_time)*24*60*60);
    END IF;

    IF p_media_rec.address = fnd_api.g_miss_char THEN
  IF p_media_rec.direction = 'INBOUND'
      AND p_media_rec.media_item_type LIKE 'TELE%'
      AND p_media_rec.ani <> fnd_api.g_miss_char THEN
    --l_address := p_media_rec.ani;
    l_media_rec.address := p_media_rec.ani;
  ELSE
    --l_address := NULL;
    l_media_rec.address := NULL;
  END IF;
 ELSE
  --l_address := p_media_rec.address;
  l_media_rec.address := p_media_rec.address;
 END IF;


    --SELECT jtf_ih_media_items_s1.NEXTVAL INTO l_media_id FROM dual;
    --l_media_id := Get_Media_Id(NULL);
    l_media_rec.media_id := Get_Media_Id(NULL);

	-- DBMS_OUTPUT.PUT_LINE('PAST generate PK in JTF_IH_PUB.Create_MediaItem');
	insert into jtf_ih_Media_Items
		(
			 DURATION,
			 DIRECTION,
			 END_DATE_TIME,
			 SOURCE_ITEM_CREATE_DATE_TIME,
			 INTERACTION_PERFORMED,
			 SOURCE_ITEM_ID,
			 START_DATE_TIME,
			 MEDIA_ID,
			 SOURCE_ID,
			 MEDIA_ITEM_TYPE,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 MEDIA_ITEM_REF,
			 MEDIA_DATA,
			 MEDIA_ABANDON_FLAG,
			 MEDIA_TRANSFERRED_FLAG,
			 ACTIVE,
       		 SERVER_GROUP_ID,
       		 DNIS,
       		 ANI,
       		 CLASSIFICATION,
       		 BULK_WRITER_CODE,
       		 BULK_BATCH_TYPE,
       		 BULK_BATCH_ID,
       		 BULK_INTERACTION_ID,
       		 ADDRESS,
       		 AO_UPDATE_PENDING,
       		 SOFT_CLOSED

		) values (
			 --decode(l_duration,fnd_api.g_miss_num, l_duration_perf, l_duration),
			 decode(l_media_rec.duration,fnd_api.g_miss_num, 0, l_media_rec.duration),
			 decode( p_media_rec.direction, fnd_api.g_miss_char, null, p_media_rec.direction),
			 --l_end_date_time,
			 l_media_rec.end_date_time,
			 --l_source_item_create_date_time,
			 l_media_rec.source_item_create_date_time,
			 decode( p_media_rec.interaction_performed, fnd_api.g_miss_char, null, p_media_rec.interaction_performed),
			 decode( p_media_rec.source_item_id, fnd_api.g_miss_num, null, p_media_rec.source_item_id),
			 --l_start_date_time,
			 l_media_rec.start_date_time,
			 --l_media_id,
			 l_media_rec.media_id,
			 decode( p_media_rec.source_id, fnd_api.g_miss_num, null, p_media_rec.source_id),
       -- Bug# 2309710
			 decode( p_media_rec.media_item_type, fnd_api.g_miss_char, null, p_media_rec.media_item_type),
			 p_user_id,
			 SysDate,
			 p_user_id,
			 SysDate,
			 p_login_id,
			 decode( p_media_rec.media_item_ref, fnd_api.g_miss_char, null,p_media_rec.media_item_ref),
			 decode( p_media_rec.media_data, fnd_api.g_miss_char, null,p_media_rec.media_data),
			 decode( p_media_rec.media_abandon_flag, fnd_api.g_miss_char, null,p_media_rec.media_abandon_flag),
			 decode( p_media_rec.media_transferred_flag, fnd_api.g_miss_char, null,p_media_rec.media_transferred_flag),
			 l_active_perf,
       		 decode( p_media_rec.server_group_id, fnd_api.g_miss_num, null,p_media_rec.server_group_id),
       		 decode( p_media_rec.dnis, fnd_api.g_miss_char, null,p_media_rec.dnis),
       		 decode( p_media_rec.ani, fnd_api.g_miss_char, null,p_media_rec.ani),
       		 decode( p_media_rec.classification, fnd_api.g_miss_char, null, p_media_rec.classification),
			 decode( p_media_rec.bulk_writer_code, fnd_api.g_miss_char, null, p_media_rec.bulk_writer_code),
			 decode( p_media_rec.bulk_batch_type, fnd_api.g_miss_char, null, p_media_rec.bulk_batch_type),
			 decode( p_media_rec.bulk_batch_id, fnd_api.g_miss_num, null, p_media_rec.bulk_batch_id),
			 decode( p_media_rec.bulk_interaction_id, fnd_api.g_miss_num, null, p_media_rec.bulk_interaction_id),
			 --decode( l_address, fnd_api.g_miss_char, null, l_address),
			 decode( l_media_rec.address, fnd_api.g_miss_char, null, l_media_rec.address),
		 l_ao_update_pending_perf,
		 l_soft_closed_perf
		);
	-- DBMS_OUTPUT.PUT_LINE('PAST Insert data in JTF_IH_PUB.Create_MediaItem');

	--
	-- Output
	--														   --
	--x_media_id := l_media_id;
	x_media_id := l_media_rec.media_id;

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_MEDIAITEM', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.create_mediaitem_post(
						     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_MEDIAITEM', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.create_mediaitem_post(
						     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
  ( p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
  ( p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
   WHEN OTHERS THEN
      ROLLBACK TO create_media_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
  ( p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
  END Create_MediaItem;


--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--					INITIAL VERSION
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--	James Baldo Jr. 26-JUL-2000	Fix for bugdb # 1314821 and 1342156
--
-- Jean Zhu split old version PROCEDURE Create_MediaItem() to
-- two PROCEDUREs Create_MediaItem() and Create_MediaLifecycle()
--  Igor Aleshin    20-MAY-2002 Modified duration calculation
--  Igor Aleshin    29-MAY-2003 Enh# 2940473 - IH Bulk API Changes
--  vekrishn        27-JUL-2004 Perf Fix for literal Usage
--
--
procedure Create_MediaLifecycle
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_media_lc_rec	IN	media_lc_rec_type
)AS

	l_api_name   	CONSTANT VARCHAR2(30) := 'Create_MediaLifecycle';
	l_api_version      	CONSTANT NUMBER       := 1.0;
	l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
	l_return_status    	VARCHAR2(1);
	--l_milcs_id   	NUMBER := NULL;
	l_return_code		VARCHAR2(1);
	l_data			VARCHAR2(2000);
	l_count			NUMBER;
	l_media_lc_rec		MEDIA_LC_REC_TYPE;
	--l_milcs_type_id		NUMBER := NULL;
	--l_start_date_time	DATE;
	--l_end_date_time		DATE;
	--l_duration		NUMBER := NULL;

  -- Perf fix for literal Usage
  l_duration_perf          NUMBER;
  l_active_perf            VARCHAR2(1);

	BEGIN
	-- Standard start of API savepoint
	SAVEPOINT create_media_lc_pub;

   -- Perf variables
   l_duration_perf := 0;
   l_active_perf := 'N';

			-- Preprocessing Call
			l_media_lc_rec := p_media_lc_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_MEDIALIFEYCYCLE', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.create_medialifecycle_pre(
						     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_MEDIALIFECYCLE', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.create_medialifecycle_pre(
						     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


	-- Standard call to check for call compatibility
	IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
      		RAISE fnd_api.g_exc_unexpected_error;
	END IF;
      --  DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Create_MediaLifecycle');
	-- Initialize message list if p_init_msg_list is set to TRUE
	IF fnd_api.to_boolean(p_init_msg_list) THEN
      		fnd_msg_pub.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := fnd_api.g_ret_sts_success;

	--
	-- Validate user and login session IDs
	--
	IF (p_user_id IS NULL) THEN
		jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
		RAISE fnd_api.g_exc_error;
	ELSE
		jtf_ih_core_util_pvt.validate_who_info
		(	p_api_name        => l_api_name_full,
			p_parameter_name_usr    => 'p_user_id',
			p_parameter_name_log    => 'p_login_id',
			p_user_id         => p_user_id,
			p_login_id        => p_login_id,
			x_return_status   => l_return_status );
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
	END IF;
	-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Create_MediaLifecycle' || p_user_id);
	-- DBMS_OUTPUT.PUT_LINE('milcs_type_id:= ' || p_media_lc_rec.milcs_type_id);
	-- DBMS_OUTPUT.PUT_LINE('milcs_type_code:= ' || p_media_lc_rec.milcs_code);
	Validate_Mlcs_Record
	(	p_api_name      => l_api_name_full,
		p_media_lc_rec	      => p_media_lc_rec,
		p_resp_appl_id  => p_resp_appl_id,
		p_resp_id       => p_resp_id,
		x_return_status       => l_return_status
		);
	IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
	END IF;
	-- DBMS_OUTPUT.PUT_LINE('PAST Validate_Mlcs_Record in JTF_IH_PUB.Create_MediaLifecycle');
	-- assign the start_date_time

	IF(p_media_lc_rec.start_date_time IS NOT NULL) AND (p_media_lc_rec.start_date_time <> fnd_api.g_miss_date) THEN
		--l_start_date_time := p_media_lc_rec.start_date_time;
		l_media_lc_rec.start_date_time := p_media_lc_rec.start_date_time;
	ELSE
		--l_start_date_time := SYSDATE;
		l_media_lc_rec.start_date_time := SYSDATE;
	END IF;

    IF(p_media_lc_rec.end_date_time <> fnd_api.g_miss_date) AND (p_media_lc_rec.end_date_time IS NOT NULL) THEN
	   --l_end_date_time := p_media_lc_rec.end_date_time;
	   l_media_lc_rec.end_date_time := p_media_lc_rec.end_date_time;
    ELSE
       --l_end_date_time := SYSDATE;
       l_media_lc_rec.end_date_time := SYSDATE;
    END IF;

    Validate_StartEnd_Date
			(	p_api_name    	=> l_api_name_full,
				--p_start_date_time   	=> l_start_date_time,
				p_start_date_time   	=> l_media_lc_rec.start_date_time,
				--p_end_date_time		=> l_end_date_time,
				p_end_date_time 	=> l_media_lc_rec.end_date_time,
				x_return_status     	=> l_return_status
			);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;

	-- assign the duration
	IF (p_media_lc_rec.duration <> fnd_api.g_miss_num) AND (p_media_lc_rec.duration IS NOT NULL) THEN
		--l_duration := p_media_lc_rec.duration;
		l_media_lc_rec.duration := p_media_lc_rec.duration;
    ELSE
       --l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
       l_media_lc_rec.duration := ROUND((l_media_lc_rec.end_date_time - l_media_lc_rec.start_date_time)*24*60*60);
    END IF;

	--l_milcs_type_id := p_media_lc_rec.milcs_type_id;
	l_media_lc_rec.milcs_type_id := p_media_lc_rec.milcs_type_id;
	IF ((p_media_lc_rec.milcs_type_id IS NULL) OR (p_media_lc_rec.milcs_type_id = FND_API.G_MISS_NUM)) THEN
		--select milcs_type_id into l_milcs_type_id
		select milcs_type_id into l_media_lc_rec.milcs_type_id
		from jtf_ih_media_itm_lc_seg_tys
		where milcs_code = p_media_lc_rec.milcs_code;
	END IF;

    -- Bug# 2817083
    --SELECT jtf_ih_media_item_lc_seg_s1.NEXTVAL INTO l_milcs_id FROM dual;
	-- DBMS_OUTPUT.PUT_LINE('PAST generate PK in JTF_IH_PUB.Create_MediaLifecycle '|| l_milcs_id);
        --l_milcs_id := Get_milcs_id(NULL);
        l_media_lc_rec.milcs_id := Get_milcs_id(NULL);

        -- Perf fix for literal Usage
	insert into jtf_ih_media_item_lc_segs
	(
			 START_DATE_TIME,
			 TYPE_TYPE,
			 TYPE_ID,
			 DURATION,
			 END_DATE_TIME,
			 MILCS_ID,
			 MILCS_TYPE_ID,
			 MEDIA_ID,
			 HANDLER_ID,
			 RESOURCE_ID,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 ACTIVE,
       BULK_WRITER_CODE,
       BULK_BATCH_TYPE,
       BULK_BATCH_ID,
       BULK_INTERACTION_ID
 	)
	values
	(
			--l_start_date_time,
			l_media_lc_rec.start_date_time,
			decode( p_media_lc_rec.type_type, fnd_api.g_miss_char, null,p_media_lc_rec.type_type),
			decode( p_media_lc_rec.type_id, fnd_api.g_miss_num, null, p_media_lc_rec.type_id),
			--decode( l_duration, fnd_api.g_miss_num, l_duration_perf, l_duration ),
			decode(l_media_lc_rec.duration, fnd_api.g_miss_num, 0, l_media_lc_rec.duration ),
			--l_end_date_time,
			l_media_lc_rec.end_date_time,
			--l_milcs_id,
			l_media_lc_rec.milcs_id,
			--decode( l_milcs_type_id, fnd_api.g_miss_num, null, l_milcs_type_id),
			decode(l_media_lc_rec.milcs_type_id, fnd_api.g_miss_num, null, l_media_lc_rec.milcs_type_id),
			p_media_lc_rec.media_id,
			p_media_lc_rec.handler_id,
			decode( p_media_lc_rec.resource_id, fnd_api.g_miss_num, null, p_media_lc_rec.resource_id),
			p_user_id,
			Sysdate,
			p_user_id,
			Sysdate,
			p_login_id,
			l_active_perf,
		    decode( p_media_lc_rec.bulk_writer_code, fnd_api.g_miss_char, null, p_media_lc_rec.bulk_writer_code),
			decode( p_media_lc_rec.bulk_batch_type, fnd_api.g_miss_char, null, p_media_lc_rec.bulk_batch_type),
			decode( p_media_lc_rec.bulk_batch_id, fnd_api.g_miss_num, null, p_media_lc_rec.bulk_batch_id),
			decode( p_media_lc_rec.bulk_interaction_id, fnd_api.g_miss_num, null, p_media_lc_rec.bulk_interaction_id)
	);
	-- DBMS_OUTPUT.PUT_LINE('PAST insert data in JTF_IH_PUB.Create_MediaLifecycle');

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_MEDIALIFECYCLE', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.create_medialifecycle_post(
						     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_MEDIALIFECYCLE', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.create_medialifecycle_post(
						     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_media_lc_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
  ( p_encoded	=> FND_API.g_false,
	  p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_media_lc_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
  ( p_encoded	=> FND_API.g_false,
	       p_count       => x_msg_count,
      p_data  => x_msg_data );
    x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
   WHEN OTHERS THEN
      ROLLBACK TO create_media_lc_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
  ( p_encoded	=> FND_API.g_false,
	       p_count       => x_msg_count,
      p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
  END Create_MediaLifecycle;

--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--					INITIAL VERSION
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--  Igor Aleshin    22-MAY-2001 - Fixed the bug# 1791550 unable to Create
--            Activity by Call Create_Interaction API
--  Igor Aleshin    21-DEC-2001 Fix for bugdb - 2153913 - PREVENT G_MISS_DATE VALUE FROM BEING
--            WRITTEN TO THE END_DATE_TIME VALUE.
--  Igor Aleshin    21-FEB-2002 Fix for bugdb - 2235155 - JTF_IH_PUB.CREATE_INTERACTION DOESN'T
--            INSERT ALL VALUES TO JTF_IH_ACTIVITIES
--  Igor Aleshin    04-MAR-2002 Added Attributes to Activity_Rec.
--  Igor Aleshin    18-APR-2001 Fix for bugdb 2323210 - 1157.6RI:API
--            ERR:JTF_IH_PUB.CLOSE_INTERACTION:WHEN DISAGREE WITH OKC IN IBE
--  Igor Aleshin    10-MAY-2002 ENH# 2079963 - NEED INTERACTION HISTORY RECORD TO SUPPORT MULTIPLE AGENTS
--  Igor Aleshin    05-JUN-2002 Removed from statemements Resource_ID for Activity_Rec_Type
--  Igor Aleshin    24-FEB-2003 Fixed bug# 2817083 - Error loggin interactions
--  Igor Aleshin    29-MAY-2003 Enh# 2940473 - IH Bulk API Changes
--  Igor Aleshin    18-JUN-2003 Enh# 1846960 - REQUIRE CONTACT NAME OF ORGANISATION IN INTERACTION HISTORY
--  vekrishn        27-JUL-2004 Perf Fix for literal Usage
--
--

PROCEDURE Create_Interaction(
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2, --DEFAULT FND_API.G_FALSE,
   p_commit          IN VARCHAR2, --DEFAULT FND_API.G_FALSE,
   p_resp_appl_id    IN NUMBER   DEFAULT NULL,
   p_resp_id         IN NUMBER   DEFAULT NULL,
   p_user_id         IN NUMBER,
   p_login_id        IN NUMBER   DEFAULT NULL,
   x_return_status   OUT NOCOPY	VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_interaction_rec IN interaction_rec_type,
   p_activities      IN activity_tbl_type
) IS
   l_api_name   CONSTANT VARCHAR2(30) := 'Create_Interaction';
   l_api_version      CONSTANT NUMBER       := 1.0;
   l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
   l_return_status    VARCHAR2(1);
   l_int_val_rec      interaction_rec_type;
   l_interaction_id   NUMBER;
   l_activity_id      NUMBER;
   l_activities 	    activity_tbl_type;
   l_return_code			VARCHAR2(1);
   l_data				VARCHAR2(2000);
   l_count				NUMBER;
   l_interaction_rec		INTERACTION_REC_TYPE;
   --l_activities_hk			activity_tbl_type;

  -- Perf fix for literal Usage
  l_duration_perf          NUMBER;
  l_active_perf            VARCHAR2(1);

BEGIN

   -- local variables initialization to remove GSCC warning
   l_int_val_rec := p_interaction_rec;
   l_activities := p_activities;


   -- Perf variables
   l_duration_perf := 0;
   l_active_perf := 'N';

   -- Standard start of API savepoint
   SAVEPOINT create_interaction_pub;

   -- Preprocessing Call
   --l_interaction_rec := p_interaction_rec;
   --l_activities_hk   := p_activities;

   IF l_activities.count = 0 THEN
      FND_MESSAGE.SET_NAME('JTF','JTF_IH_NO_ACTIVITY');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_INTERACTION', 'B', 'C') THEN
      JTF_IH_PUB_CUHK.create_interaction_pre(
         --p_interaction_rec=>l_interaction_rec,
         p_interaction_rec=>l_int_val_rec,
         --p_activities=>l_activities_hk,
         p_activities=>l_activities,
         x_data=>l_data,
         x_count=>l_count,
         x_return_code=>l_return_code);
      IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_INTERACTION', 'B', 'V') THEN
      JTF_IH_PUB_VUHK.create_interaction_pre(
         --p_interaction_rec=>l_interaction_rec,
         p_interaction_rec=>l_int_val_rec,
         --p_activities=>l_activities_hk,
         p_activities=>l_activities,
         x_data=>l_data,
         x_count=>l_count,
         x_return_code=>l_return_code);
      IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;


   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
      l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Create_Interaction');

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   --
   -- Apply business-rule validation to all required and passed parameters
   --
   -- Validate user and login session IDs
   --
   IF (p_user_id IS NULL) THEN
      jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
      RAISE fnd_api.g_exc_error;
   ELSE
      jtf_ih_core_util_pvt.validate_who_info
         ( p_api_name        => l_api_name_full,
         p_parameter_name_usr    => 'p_user_id',
         p_parameter_name_log    => 'p_login_id',
         p_user_id         => p_user_id,
         p_login_id        => p_login_id,
         x_return_status   => l_return_status );
      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;
   -- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Create_Interaction');

   --
   -- Validate all non-missing attributes by calling the utility procedure.
   --
   Validate_Interaction_Record
      ( p_api_name      => l_api_name_full,
      --p_int_val_rec   => p_interaction_rec,
      p_int_val_rec   => l_int_val_rec,
      p_resp_appl_id  => p_resp_appl_id,
      p_resp_id       => p_resp_id,
      x_return_status       => l_return_status
      );
   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   --DBMS_OUTPUT.PUT_LINE('PAST Validate_Interaction_Record in JTF_IH_PUB.Create_Interaction');
   -- mpetrosi 9/1/03 - should not default with zeroes
   -- Default_Interaction_Record(l_int_val_rec);

   -- Changed by IAleshin - 20-MAY-2002
   IF (p_interaction_rec.end_date_time <> fnd_api.g_miss_date) AND (p_interaction_rec.end_date_time IS NOT NULL) THEN
      l_int_val_rec.end_date_time := p_interaction_rec.end_date_time;
   ELSE
      l_int_val_rec.end_date_time := SYSDATE;
   END IF;

   IF (p_interaction_rec.start_date_time <> fnd_api.g_miss_date) AND (p_interaction_rec.start_date_time IS NOT NULL) THEN
      l_int_val_rec.start_date_time := p_interaction_rec.start_date_time;
   ELSE
      l_int_val_rec.start_date_time := SYSDATE;
   END IF;

   Validate_StartEnd_Date( p_api_name => l_api_name_full,
      p_start_date_time => l_int_val_rec.start_date_time,
      p_end_date_time   => l_int_val_rec.end_date_time,
      x_return_status   => l_return_status);
   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (p_interaction_rec.duration IS NOT NULL) AND (p_interaction_rec.duration <> fnd_api.g_miss_num) THEN
      l_int_val_rec.duration := l_interaction_rec.duration;
   ELSE
      l_int_val_rec.duration := ROUND((l_int_val_rec.end_date_time - l_int_val_rec.start_date_time)*24*60*60);
   END IF;

   -- Bug# 2817083
   --IF ((p_interaction_rec.interaction_id IS NULL) OR (p_interaction_rec.interaction_id = fnd_api.g_miss_num)) THEN
   --    SELECT jtf_ih_interactions_s1.NEXTVAL INTO l_int_val_rec.interaction_id FROM dual;
   --END IF;
   l_int_val_rec.interaction_id := Get_Interaction_ID(p_interaction_rec.interaction_id);
   IF l_int_val_rec.interaction_id = -1 THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   Validate_Source_Code(l_api_name_full,l_int_val_rec.source_code_id,l_int_val_rec.source_code, x_return_status);
   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   -- Perf fix for literal Usage
   INSERT INTO jtf_ih_Interactions
   (
      CREATED_BY,
      REFERENCE_FORM,
      CREATION_DATE,
      LAST_UPDATED_BY,
      DURATION,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      END_DATE_TIME,
      FOLLOW_UP_ACTION,
      NON_PRODUCTIVE_TIME_AMOUNT,
      RESULT_ID,
      REASON_ID,
      START_DATE_TIME,
      OUTCOME_ID,
      PREVIEW_TIME_AMOUNT,
      PRODUCTIVE_TIME_AMOUNT,
      HANDLER_ID,
      INTER_INTERACTION_DURATION,
      INTERACTION_ID,
      WRAP_UP_TIME_AMOUNT,
      SCRIPT_ID,
      PARTY_ID,
      RESOURCE_ID,
      OBJECT_ID,
      OBJECT_TYPE,
      SOURCE_CODE_ID,
      SOURCE_CODE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      ACTIVE,
      TOUCHPOINT1_TYPE,
      TOUCHPOINT2_TYPE,
      METHOD_CODE,
      BULK_WRITER_CODE,
      BULK_BATCH_TYPE,
      BULK_BATCH_ID,
      BULK_INTERACTION_ID,
      PRIMARY_PARTY_ID,
      CONTACT_REL_PARTY_ID,
      CONTACT_PARTY_ID
   )
   VALUES
   (
      p_user_id,
      decode( l_int_val_rec.reference_form, fnd_api.g_miss_char, null, l_int_val_rec.reference_form),
      Sysdate,
      p_user_id,
      decode( l_int_val_rec.duration, fnd_api.g_miss_num, l_duration_perf, l_int_val_rec.duration),
      Sysdate,
      p_login_id,
      l_int_val_rec.end_date_time,
      decode( l_int_val_rec.follow_up_action, fnd_api.g_miss_char, null, l_int_val_rec.follow_up_action),
      decode( l_int_val_rec.non_productive_time_amount, fnd_api.g_miss_num, null, l_int_val_rec.non_productive_time_amount),
      decode( l_int_val_rec.result_id, fnd_api.g_miss_num, null, l_int_val_rec.result_id),
      decode( l_int_val_rec.reason_id, fnd_api.g_miss_num, null, l_int_val_rec.reason_id),
      l_int_val_rec.start_date_time,
      decode( l_int_val_rec.outcome_id, fnd_api.g_miss_num, null, l_int_val_rec.outcome_id),
      decode( l_int_val_rec.preview_time_amount, fnd_api.g_miss_num, null, l_int_val_rec.preview_time_amount),
      decode( l_int_val_rec.productive_time_amount, fnd_api.g_miss_num, null, l_int_val_rec.productive_time_amount),
      l_int_val_rec.handler_id,
      decode( l_int_val_rec.inter_interaction_duration, fnd_api.g_miss_num, null, l_int_val_rec.inter_interaction_duration),
      l_int_val_rec.interaction_id,
      decode( l_int_val_rec.wrapup_time_amount, fnd_api.g_miss_num, null, l_int_val_rec.wrapup_time_amount),
      decode( l_int_val_rec.script_id, fnd_api.g_miss_num, null, l_int_val_rec.script_id),
      l_int_val_rec.party_id,
      l_int_val_rec.resource_id,
      decode( l_int_val_rec.object_id, fnd_api.g_miss_num, null, l_int_val_rec.object_id),
      decode( l_int_val_rec.object_type, fnd_api.g_miss_char, null, l_int_val_rec.object_type),
      decode( l_int_val_rec.source_code_id, fnd_api.g_miss_num, null, l_int_val_rec.source_code_id),
      decode( l_int_val_rec.source_code, fnd_api.g_miss_char, null, l_int_val_rec.source_code),
      decode( l_int_val_rec.attribute1, fnd_api.g_miss_char, null, l_int_val_rec.attribute1),
      decode( l_int_val_rec.attribute2, fnd_api.g_miss_char, null, l_int_val_rec.attribute2),
      decode( l_int_val_rec.attribute3, fnd_api.g_miss_char, null, l_int_val_rec.attribute3),
      decode( l_int_val_rec.attribute4, fnd_api.g_miss_char, null, l_int_val_rec.attribute4),
      decode( l_int_val_rec.attribute5, fnd_api.g_miss_char, null, l_int_val_rec.attribute5),
      decode( l_int_val_rec.attribute6, fnd_api.g_miss_char, null, l_int_val_rec.attribute6),
      decode( l_int_val_rec.attribute7, fnd_api.g_miss_char, null, l_int_val_rec.attribute7),
      decode( l_int_val_rec.attribute8, fnd_api.g_miss_char, null, l_int_val_rec.attribute8),
      decode( l_int_val_rec.attribute9, fnd_api.g_miss_char, null, l_int_val_rec.attribute9),
      decode( l_int_val_rec.attribute10, fnd_api.g_miss_char, null, l_int_val_rec.attribute10),
      decode( l_int_val_rec.attribute11, fnd_api.g_miss_char, null, l_int_val_rec.attribute11),
      decode( l_int_val_rec.attribute12, fnd_api.g_miss_char, null, l_int_val_rec.attribute12),
      decode( l_int_val_rec.attribute13, fnd_api.g_miss_char, null, l_int_val_rec.attribute13),
      decode( l_int_val_rec.attribute14, fnd_api.g_miss_char, null, l_int_val_rec.attribute14),
      decode( l_int_val_rec.attribute15, fnd_api.g_miss_char, null, l_int_val_rec.attribute15),
      decode( l_int_val_rec.attribute_category, fnd_api.g_miss_char, null, l_int_val_rec.attribute_category),
      l_active_perf,
      decode( l_int_val_rec.touchpoint1_type, fnd_api.g_miss_char, null, l_int_val_rec.touchpoint1_type),
      decode( l_int_val_rec.touchpoint2_type, fnd_api.g_miss_char, null, l_int_val_rec.touchpoint2_type),
      decode( l_int_val_rec.method_code, fnd_api.g_miss_char, null, l_int_val_rec.method_code),
      decode( l_int_val_rec.bulk_writer_code, fnd_api.g_miss_char, null, l_int_val_rec.bulk_writer_code),
      decode( l_int_val_rec.bulk_batch_type, fnd_api.g_miss_char, null, l_int_val_rec.bulk_batch_type),
      decode( l_int_val_rec.bulk_batch_id, fnd_api.g_miss_num, null, l_int_val_rec.bulk_batch_id),
      decode( l_int_val_rec.bulk_interaction_id, fnd_api.g_miss_num, null, l_int_val_rec.bulk_interaction_id),
      decode( l_int_val_rec.primary_party_id, fnd_api.g_miss_num, null, l_int_val_rec.primary_party_id),
      decode( l_int_val_rec.contact_rel_party_id, fnd_api.g_miss_num, null, l_int_val_rec.contact_rel_party_id),
      decode( l_int_val_rec.contact_party_id, fnd_api.g_miss_num, null, l_int_val_rec.contact_party_id)
   );

   -- DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_Interactions in JTF_IH_PUB.Create_Interaction');
   --1791550
   --
   for  idx in 1 .. l_activities.count loop
      l_activities(idx).interaction_id := l_int_val_rec.interaction_id;
   end loop;

   Validate_Activity_table
   (
      p_api_name      => l_api_name_full,
      --p_int_val_tbl   => p_activities,
      p_int_val_tbl   => l_activities,
      p_resp_appl_id  => p_resp_appl_id,
      p_resp_id       => p_resp_id,
      x_return_status       => l_return_status
   );
   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   -- mpetrosi 9/01/03 - should not default with zeroes
   -- Default_activity_table(l_activities);

   for  idx in 1 .. p_activities.count loop
      --Bug# 2817083
      --IF ((p_activities(idx).activity_id IS NULL) OR (p_activities(idx).activity_id = fnd_api.g_miss_num)) THEN
      --     SELECT jtf_ih_activities_s1.NEXTVAL INTO l_activities(idx).activity_id FROM dual;
      --END IF;

      -- Bug# 2323210
      if(p_activities(idx).start_date_time <> fnd_api.g_miss_date) AND (p_activities(idx).start_date_time IS NOT NULL) then
         l_activities(idx).start_date_time := p_activities(idx).start_date_time;
      else
         l_activities(idx).start_date_time := SYSDATE;
      end if;

      if(p_activities(idx).end_date_time <> fnd_api.g_miss_date) AND (p_activities(idx).end_date_time IS NOT NULL) then
         l_activities(idx).end_date_time := p_activities(idx).end_date_time;
      else
         l_activities(idx).end_date_time := SYSDATE;
      end if;

      if (p_activities(idx).duration <> fnd_api.g_miss_num) and (p_activities(idx).duration is not null) then
         l_activities(idx).duration := p_activities(idx).duration;
      else
         l_activities(idx).duration := ROUND((l_activities(idx).end_date_time - l_activities(idx).start_date_time)*24*60*60);
      end if;

      -- Bug 2817083
      l_activities(idx).activity_id := Get_Activity_ID(l_activities(idx).activity_id);
      IF l_activities(idx).activity_id = -1 THEN
         RAISE fnd_api.g_exc_error;
      END IF;


      -- Removed by IAleshin 06/04/2002
      -- Enh# 2079963
    /* IF( p_activities(idx).resource_id IS NOT NULL) AND (p_activities(idx).resource_id <> fnd_api.g_miss_num) THEN
   	    SELECT count(resource_id) into l_count
      FROM jtf_rs_resource_extns
      WHERE resource_id = p_activities(idx).resource_id;
          IF (l_count <= 0) THEN
     	        x_return_status := fnd_api.g_ret_sts_error;
     	        jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_activities(idx).resource_id),'resource_id');
	         RETURN;
	           END IF;
        l_activities(idx).resource_id := p_activities(idx).resource_id;
    ELSE
        -- If resource_id is null or g_miss_num, then get value from parent interaction
        l_activities(idx).resource_id := l_int_val_rec.resource_id;
    END IF;*/

      -- 08/29/03 mpetrosi B3102306
      -- added cross check of source_code, source_code_id
      Validate_Source_Code(l_api_name_full,l_activities(idx).source_code_id,l_activities(idx).source_code, x_return_status);
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
      END IF;

      -- DBMS_OUTPUT.PUT_LINE('PAST activity id validation');
      insert into jtf_ih_Activities
      (
         OBJECT_ID,
         OBJECT_TYPE,
         SOURCE_CODE_ID,
         SOURCE_CODE,
         DURATION,
         DESCRIPTION,
         DOC_ID,
         END_DATE_TIME,
         ACTIVITY_ID,
         RESULT_ID,
         REASON_ID,
         START_DATE_TIME,
         INTERACTION_ACTION_TYPE,
         MEDIA_ID,
         OUTCOME_ID,
         ACTION_ITEM_ID,
         INTERACTION_ID,
         TASK_ID,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         ACTION_ID,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         ATTRIBUTE_CATEGORY,
         ACTIVE,
         SCRIPT_TRANS_ID,
         ROLE,
         DOC_SOURCE_OBJECT_NAME,
         --, RESOURCE_ID
         -- Added missed columns 09/10/2002
         CUST_ACCOUNT_ID,
         CUST_ORG_ID,
         DOC_REF,
         BULK_WRITER_CODE,
         BULK_BATCH_TYPE,
         BULK_BATCH_ID,
         BULK_INTERACTION_ID
      )
      values
      (
         decode( l_activities(idx).object_id, fnd_api.g_miss_num, null, l_activities(idx).object_id),
         decode( l_activities(idx).object_type, fnd_api.g_miss_char, null, l_activities(idx).object_type),
         decode( l_activities(idx).source_code_id, fnd_api.g_miss_num, null, l_activities(idx).source_code_id),
         decode( l_activities(idx).source_code, fnd_api.g_miss_char, null, l_activities(idx).source_code),
         decode( l_activities(idx).duration, fnd_api.g_miss_num, l_duration_perf, l_activities(idx).duration),
         decode( l_activities(idx).description, fnd_api.g_miss_char, null, l_activities(idx).description),
         decode( l_activities(idx).doc_id, fnd_api.g_miss_num, null, l_activities(idx).doc_id),
         l_activities(idx).end_date_time,
         l_activities(idx).activity_id,
         decode( l_activities(idx).result_id, fnd_api.g_miss_num, null, l_activities(idx).result_id),
         decode( l_activities(idx).reason_id, fnd_api.g_miss_num, null, l_activities(idx).reason_id),
         l_activities(idx).start_date_time,
         decode( l_activities(idx).interaction_action_type, fnd_api.g_miss_char, null, l_activities(idx).interaction_action_type),
         decode( l_activities(idx).media_id, fnd_api.g_miss_num, null, l_activities(idx).media_id),
         decode( l_activities(idx).outcome_id, fnd_api.g_miss_num, null, l_activities(idx).outcome_id),
         decode( l_activities(idx).action_item_id, fnd_api.g_miss_num, null, l_activities(idx).action_item_id),
         l_int_val_rec.interaction_id,
         decode( l_activities(idx).task_id, fnd_api.g_miss_num, null, l_activities(idx).task_id),
         Sysdate,
         p_user_id,
         p_user_id,
         Sysdate,
         p_login_id,
         decode( l_activities(idx).action_id, fnd_api.g_miss_num, null, l_activities(idx).action_id),
         decode( l_activities(idx).attribute1, fnd_api.g_miss_char, null, l_activities(idx).attribute1),
         decode( l_activities(idx).attribute2, fnd_api.g_miss_char, null, l_activities(idx).attribute2),
         decode( l_activities(idx).attribute3, fnd_api.g_miss_char, null, l_activities(idx).attribute3),
         decode( l_activities(idx).attribute4, fnd_api.g_miss_char, null, l_activities(idx).attribute4),
         decode( l_activities(idx).attribute5, fnd_api.g_miss_char, null, l_activities(idx).attribute5),
         decode( l_activities(idx).attribute6, fnd_api.g_miss_char, null, l_activities(idx).attribute6),
         decode( l_activities(idx).attribute7, fnd_api.g_miss_char, null, l_activities(idx).attribute7),
         decode( l_activities(idx).attribute8, fnd_api.g_miss_char, null, l_activities(idx).attribute8),
         decode( l_activities(idx).attribute9, fnd_api.g_miss_char, null, l_activities(idx).attribute9),
         decode( l_activities(idx).attribute10, fnd_api.g_miss_char, null, l_activities(idx).attribute10),
         decode( l_activities(idx).attribute11, fnd_api.g_miss_char, null, l_activities(idx).attribute11),
         decode( l_activities(idx).attribute12, fnd_api.g_miss_char, null, l_activities(idx).attribute12),
         decode( l_activities(idx).attribute13, fnd_api.g_miss_char, null, l_activities(idx).attribute13),
         decode( l_activities(idx).attribute14, fnd_api.g_miss_char, null, l_activities(idx).attribute14),
         decode( l_activities(idx).attribute15, fnd_api.g_miss_char, null, l_activities(idx).attribute15),
         decode( l_activities(idx).attribute_category, fnd_api.g_miss_char, null, l_activities(idx).attribute_category),
         l_active_perf,
         decode( l_activities(idx).script_trans_id, fnd_api.g_miss_num, null, l_activities(idx).script_trans_id),
         decode( l_activities(idx).role, fnd_api.g_miss_char, null, l_activities(idx).role),
         decode( l_activities(idx).doc_source_object_name, fnd_api.g_miss_char, null,l_activities(idx).doc_source_object_name),
         --, l_activities(idx).resource_id
         -- Added missed columns 09/10/2002
         decode( l_activities(idx).cust_account_id, fnd_api.g_miss_num, null, l_activities(idx).cust_account_id),
         decode( l_activities(idx).cust_org_id, fnd_api.g_miss_num, null, l_activities(idx).cust_org_id),
         decode( l_activities(idx).doc_ref, fnd_api.g_miss_char, null, l_activities(idx).doc_ref),
         decode( l_activities(idx).bulk_writer_code, fnd_api.g_miss_char, null, l_activities(idx).bulk_writer_code),
         decode( l_activities(idx).bulk_batch_type, fnd_api.g_miss_char, null, l_activities(idx).bulk_batch_type),
         decode( l_activities(idx).bulk_batch_id, fnd_api.g_miss_num, null, l_activities(idx).bulk_batch_id),
         decode( l_activities(idx).bulk_interaction_id, fnd_api.g_miss_num, null, l_activities(idx).bulk_interaction_id)
      );
   END loop;

   -- DBMS_OUTPUT.PUT_LINE('PAST insert into activities');
   IF ((l_int_val_rec.parent_id IS NOT NULL) AND (l_int_val_rec.parent_id  <> fnd_api.g_miss_num))	THEN
      insert into jtf_ih_interaction_inters
      (
         INTERACT_INTERACTION_ID,
         INTERACT_INTERACTION_IDRELATES,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN
      )
      values
      (
         l_int_val_rec.interaction_id,
         l_int_val_rec.parent_id,
         p_user_id,
         Sysdate,
         p_user_id,
         Sysdate,
         p_user_id
      );
   END IF;

   --
   -- Set OUT value
   --
   --x_interaction_id := l_int_val_rec.interaction_id;

   -- Post processing Call

   IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_INTERACTION', 'A', 'V') THEN
      JTF_IH_PUB_VUHK.create_interaction_post(
         --p_interaction_rec=>l_interaction_rec,
         p_interaction_rec=>l_int_val_rec,
         --p_activities=>l_activities_hk,
         p_activities=>l_activities,
         x_data=>l_data,
         x_count=>l_count,
         x_return_code=>l_return_code);
      IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CREATE_INTERACTION', 'A', 'C') THEN
      JTF_IH_PUB_CUHK.create_interaction_post(
         --p_interaction_rec=>l_interaction_rec,
         p_interaction_rec=>l_int_val_rec,
         --p_activities=>l_activities_hk,
         p_activities=>l_activities,
         x_data=>l_data,
         x_count=>l_count,
         x_return_code=>l_return_code);
      IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;


   -- Standard check of p_commit
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_interaction_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
       ( p_count       => x_msg_count,
         p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_interaction_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
      ( p_count       => x_msg_count,
        p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');

   WHEN OTHERS THEN
      ROLLBACK TO create_interaction_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
      ( p_count       => x_msg_count,
        p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
  END Create_Interaction;


--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--					INITIAL VERSION
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--	James Baldo Jr.	31-JUL-2000	Implementation fix for bugdb # 1340799
--

	PROCEDURE Get_InteractionActivityCount
	(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER   DEFAULT NULL,
	p_resp_id		IN	NUMBER   DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER   DEFAULT NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_outcome_id   	IN 	NUMBER,
	p_result_id    	IN 	NUMBER,
	p_reason_id    	IN 	NUMBER,
	p_script_id    		IN 	NUMBER,
	p_media_id     		IN 	NUMBER,
	x_activity_count 	OUT NOCOPY	NUMBER
  ) AS
	l_api_name   	CONSTANT VARCHAR2(30) := 'Get_InteractionActivityCount';
	l_api_version      	CONSTANT NUMBER       := 1.0;
	l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
	l_return_status    	VARCHAR2(1);
	actionCount 		NUMBER;
	l_return_code		VARCHAR2(1);
	l_data			VARCHAR2(2000);
	l_count			NUMBER;
	l_outcome_id 		NUMBER;
	l_result_id 		NUMBER;
	l_reason_id 		NUMBER;
	l_script_id 		NUMBER;
	l_media_id 		NUMBER;

   BEGIN
	-- Preprocessing Call
	l_outcome_id := p_outcome_id;
	l_result_id := p_result_id;
	l_reason_id := p_reason_id;
	l_script_id := p_script_id;
	l_media_id := p_media_id;
	IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'GET_INTERACTIONACTIVITYCOUNT', 'B', 'C') THEN
		JTF_IH_PUB_CUHK.get_interactionactcnt_pre(
							p_outcome_id=>l_outcome_id,
							p_result_id=>l_result_id,
							p_reason_id=>l_reason_id,
							p_script_id=>l_script_id,
							p_media_id=>l_media_id,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

	IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'GET_INTERACTIONACTIVITYCOUNT', 'B', 'V') THEN
		JTF_IH_PUB_VUHK.get_interactionactcnt_pre(
							p_outcome_id=>l_outcome_id,
							p_result_id=>l_result_id,
							p_reason_id=>l_reason_id,
							p_script_id=>l_script_id,
							p_media_id=>l_media_id,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

   	IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
      		RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF fnd_api.to_boolean(p_init_msg_list) THEN
      		fnd_msg_pub.initialize;
	END IF;

   	-- Initialize API return status to success
   	x_return_status := fnd_api.g_ret_sts_success;

   	--
   	-- Apply business-rule validation to all required and passed parameters
    --
    -- Validate user and login session IDs
    --
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--
		-- There are 2**4 combinations for this search
		--
		-- Case one all parameters valid
		--
		IF (((p_outcome_id IS NOT NULL) OR (p_outcome_id <> fnd_api.g_miss_num)) AND
		    ((p_result_id IS NOT NULL) OR (p_result_id <> fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NOT NULL) OR (p_reason_id <> fnd_api.g_miss_num)) AND
		    ((p_media_id IS NOT NULL) OR (p_media_id <> fnd_api.g_miss_num))) THEN

			SELECT count(activity_id) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and  result_id = p_result_id
			and reason_id = p_reason_id
			and media_id = p_media_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS NOT NULL) OR (p_outcome_id <> fnd_api.g_miss_num)) AND
		    ((p_result_id IS NOT NULL) OR (p_result_id <> fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NOT NULL) OR (p_reason_id <> fnd_api.g_miss_num)) AND
		    ((p_media_id IS NULL) OR (p_media_id = fnd_api.g_miss_num))) THEN

			SELECT count(activity_id) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and  result_id = p_result_id
			and reason_id = p_reason_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS NOT NULL) OR (p_outcome_id <> fnd_api.g_miss_num)) AND
		    ((p_result_id IS NOT NULL) OR (p_result_id <> fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NULL) OR (p_reason_id = fnd_api.g_miss_num)) AND
		    ((p_media_id IS NOT NULL) OR (p_media_id <> fnd_api.g_miss_num))) THEN

			SELECT count(activity_id) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and  result_id = p_result_id
			and media_id = p_media_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS NOT NULL) OR (p_outcome_id <> fnd_api.g_miss_num)) AND
		    ((p_result_id IS NOT NULL) OR (p_result_id <> fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NULL) OR (p_reason_id = fnd_api.g_miss_num)) AND
		    ((p_media_id IS NULL) OR (p_media_id = fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and  result_id = p_result_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS NOT NULL) OR (p_outcome_id <> fnd_api.g_miss_num)) AND
		    ((p_result_id IS  NULL) OR (p_result_id = fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NOT NULL) OR (p_reason_id <> fnd_api.g_miss_num)) AND
		    ((p_media_id IS NOT NULL) OR (p_media_id <> fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and reason_id = p_reason_id
			and media_id = p_media_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS NOT NULL) OR (p_outcome_id <> fnd_api.g_miss_num)) AND
		    ((p_result_id IS  NULL) OR (p_result_id = fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NOT NULL) OR (p_reason_id <> fnd_api.g_miss_num)) AND
		    ((p_media_id IS  NULL) OR (p_media_id = fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and reason_id = p_reason_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS NOT NULL) OR (p_outcome_id <> fnd_api.g_miss_num)) AND
		    ((p_result_id IS  NULL) OR (p_result_id = fnd_api.g_miss_num)) AND
		    ((p_reason_id IS  NULL) OR (p_reason_id = fnd_api.g_miss_num)) AND
		    ((p_media_id IS NOT NULL) OR (p_media_id <> fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and media_id = p_media_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS NOT NULL) OR (p_outcome_id <> fnd_api.g_miss_num)) AND
		    ((p_result_id IS  NULL) OR (p_result_id = fnd_api.g_miss_num)) AND
		    ((p_reason_id IS  NULL) OR (p_reason_id = fnd_api.g_miss_num)) AND
		    ((p_media_id IS  NULL) OR (p_media_id = fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS  NULL) OR (p_outcome_id = fnd_api.g_miss_num)) AND
		    ((p_result_id IS NOT NULL) OR (p_result_id <> fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NOT NULL) OR (p_reason_id <> fnd_api.g_miss_num)) AND
		    ((p_media_id IS NOT NULL) OR (p_media_id <> fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and  result_id = p_result_id
			and reason_id = p_reason_id
			and media_id = p_media_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS  NULL) OR (p_outcome_id = fnd_api.g_miss_num)) AND
		    ((p_result_id IS NOT NULL) OR (p_result_id <> fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NOT NULL) OR (p_reason_id <> fnd_api.g_miss_num)) AND
		    ((p_media_id IS NULL) OR (p_media_id = fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and  result_id = p_result_id
			and reason_id = p_reason_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS  NULL) OR (p_outcome_id = fnd_api.g_miss_num)) AND
		    ((p_result_id IS NOT NULL) OR (p_result_id <> fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NULL) OR (p_reason_id = fnd_api.g_miss_num)) AND
		    ((p_media_id IS NOT NULL) OR (p_media_id <> fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and  result_id = p_result_id
			and media_id = p_media_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS  NULL) OR (p_outcome_id = fnd_api.g_miss_num)) AND
		    ((p_result_id IS NOT NULL) OR (p_result_id <> fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NULL) OR (p_reason_id = fnd_api.g_miss_num)) AND
		    ((p_media_id IS NULL) OR (p_media_id = fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and  result_id = p_result_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS  NULL) OR (p_outcome_id = fnd_api.g_miss_num)) AND
		    ((p_result_id IS  NULL) OR (p_result_id = fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NOT NULL) OR (p_reason_id <> fnd_api.g_miss_num)) AND
		    ((p_media_id IS NOT NULL) OR (p_media_id <> fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and reason_id = p_reason_id
			and media_id = p_media_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS  NULL) OR (p_outcome_id = fnd_api.g_miss_num)) AND
		    ((p_result_id IS  NULL) OR (p_result_id = fnd_api.g_miss_num)) AND
		    ((p_reason_id IS NOT NULL) OR (p_reason_id <> fnd_api.g_miss_num)) AND
		    ((p_media_id IS  NULL) OR (p_media_id = fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and reason_id = p_reason_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS  NULL) OR (p_outcome_id = fnd_api.g_miss_num)) AND
		    ((p_result_id IS  NULL) OR (p_result_id = fnd_api.g_miss_num)) AND
		    ((p_reason_id IS  NULL) OR (p_reason_id = fnd_api.g_miss_num)) AND
		    ((p_media_id IS NOT NULL) OR (p_media_id <> fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			and media_id = p_media_id
			;
			x_activity_count := actionCount;
		ELSIF (((p_outcome_id IS  NULL) OR (p_outcome_id = fnd_api.g_miss_num)) AND
		    ((p_result_id IS  NULL) OR (p_result_id = fnd_api.g_miss_num)) AND
		    ((p_reason_id IS  NULL) OR (p_reason_id = fnd_api.g_miss_num)) AND
		    ((p_media_id IS  NULL) OR (p_media_id = fnd_api.g_miss_num))) THEN

			SELECT count(*) into actionCount
			FROM jtf_ih_Activities
			where outcome_id = p_outcome_id
			;
			x_activity_count := actionCount;
		END IF;


		-- Post processing Call
	IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'GET_INTERACTIONACTIVITYCOUNT', 'B', 'V') THEN
		JTF_IH_PUB_VUHK.get_interactionactcnt_post(
							p_outcome_id=>l_outcome_id,
							p_result_id=>l_result_id,
							p_reason_id=>l_reason_id,
							p_script_id=>l_script_id,
							p_media_id=>l_media_id,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

	IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'GET_INTERACTIONACTIVITYCOUNT', 'B', 'C') THEN
		JTF_IH_PUB_CUHK.get_interactionactcnt_post(
							p_outcome_id=>l_outcome_id,
							p_result_id=>l_result_id,
							p_reason_id=>l_reason_id,
							p_script_id=>l_script_id,
							p_media_id=>l_media_id,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
  ( p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
  ( p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
  ( p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Get_InteractionActivityCount;

--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--					INITIAL VERSION
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--
	PROCEDURE Get_InteractionCount
	(
	p_api_version		IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2, --DEFAULT FND_API.G_FALSE,
  p_resp_appl_id		IN	NUMBER   DEFAULT NULL,
  p_resp_id			IN	NUMBER   DEFAULT NULL,
  p_user_id			IN	NUMBER,
  p_login_id			IN	NUMBER   DEFAULT NULL,
  x_return_status		OUT NOCOPY	VARCHAR2,
  x_msg_count			OUT NOCOPY	NUMBER,
  x_msg_data			OUT NOCOPY	VARCHAR2,
	p_outcome_id   IN NUMBER,
	p_result_id    IN NUMBER,
	p_reason_id    IN NUMBER,
	p_attribute1			IN	VARCHAR2 DEFAULT NULL,
  p_attribute2			IN	VARCHAR2 DEFAULT NULL,
  p_attribute3			IN	VARCHAR2 DEFAULT NULL,
  p_attribute4			IN	VARCHAR2 DEFAULT NULL,
  p_attribute5			IN	VARCHAR2 DEFAULT NULL,
  p_attribute6			IN	VARCHAR2 DEFAULT NULL,
  p_attribute7			IN	VARCHAR2 DEFAULT NULL,
  p_attribute8			IN	VARCHAR2 DEFAULT NULL,
  p_attribute9			IN	VARCHAR2 DEFAULT NULL,
  p_attribute10		IN	VARCHAR2 DEFAULT NULL,
  p_attribute11		IN	VARCHAR2 DEFAULT NULL,
  p_attribute12		IN	VARCHAR2 DEFAULT NULL,
  p_attribute13		IN	VARCHAR2 DEFAULT NULL,
  p_attribute14		IN	VARCHAR2 DEFAULT NULL,
  p_attribute15		IN	VARCHAR2 DEFAULT NULL,
  p_attribute_category  IN      VARCHAR2 DEFAULT NULL,
  x_interaction_count OUT NOCOPY NUMBER
	) AS
	l_api_name   	CONSTANT VARCHAR2(30) := 'Get_InteractionCount';
	l_api_version      	CONSTANT NUMBER       := 1.1;
	l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
	l_return_status    	VARCHAR2(1);
	interactionCount 	NUMBER;
	l_return_code		VARCHAR2(1);
	l_data			VARCHAR2(2000);
	l_count			NUMBER;
	l_outcome_id 		NUMBER;
	l_result_id 		NUMBER;
	l_reason_id 		NUMBER;

	BEGIN
	-- Preprocessing Call
	l_outcome_id := p_outcome_id;
	l_result_id := p_result_id;
	l_reason_id := p_reason_id;
	IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'GET_INTERACTIONCOUNT', 'B', 'C') THEN
		JTF_IH_PUB_CUHK.get_interactioncount_pre(
							p_outcome_id=>l_outcome_id,
							p_result_id=>l_result_id,
							p_reason_id=>l_reason_id,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

	IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'GET_INTERACTIONCOUNT', 'B', 'V') THEN
		JTF_IH_PUB_VUHK.get_interactioncount_pre(
							p_outcome_id=>l_outcome_id,
							p_result_id=>l_result_id,
							p_reason_id=>l_reason_id,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
		END IF;

   	-- Initialize API return status to success
   	x_return_status := fnd_api.g_ret_sts_success;

   	--
   	-- Apply business-rule validation to all required and passed parameters
    --
    -- Validate user and login session IDs
    --
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;

		SELECT count(*) into interactionCount
		FROM jtf_ih_Interactions
		where outcome_id = p_outcome_id
		and result_id = p_result_id
		and reason_id = p_reason_id
	--	and (attribute1 = p_attribute1) -- or (p_attribute1 is NULL and attribute1 is NULL))
	--	and (attribute2 = p_attribute2) -- or (p_attribute2 is NULL and attribute2 is NULL))
	--	and (attribute3 = p_attribute3) -- or (p_attribute3 is NULL and attribute3 is NULL))
	--	and (attribute4 = p_attribute4) -- or (p_attribute4 is NULL and attribute4 is NULL))
	--	and (attribute5 = p_attribute5) -- or (p_attribute5 is NULL and attribute5 is NULL))
	--	and (attribute6 = p_attribute6) -- or (p_attribute6 is NULL and attribute6 is NULL))
--		and (attribute7 = p_attribute7) -- or (p_attribute7 is NULL and attribute7 is NULL))
--		and (attribute8 = p_attribute8) -- or (p_attribute8 is NULL and attribute8 is NULL))
--		and (attribute9 = p_attribute9) -- or (p_attribute9 is NULL and attribute9 is NULL))
--		and (attribute10 = p_attribute10) -- or (p_attribute10 is NULL and attribute10 is NULL))
--		and (attribute11 = p_attribute11) -- or (p_attribute11 is NULL and attribute11 is NULL))
--		and (attribute12 = p_attribute12) -- or (p_attribute12 is NULL and attribute12 is NULL))
--		and (attribute13 = p_attribute13) -- or (p_attribute13 is NULL and attribute13 is NULL))
--		and (attribute14 = p_attribute14) -- or (p_attribute14 is NULL and attribute14 is NULL))
--		and (attribute15 = p_attribute15) -- or (p_attribute15 is NULL and attribute15 is NULL))
--		and (p_attribute_category = p_attribute_category) -- or (p_attribute_category is NULL and p_attribute_category is NULL))
		;
		x_interaction_count := interactionCount;
	-- Post processing Call
	IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'GET_INTERACTIONCOUNT', 'B', 'V') THEN
		JTF_IH_PUB_VUHK.get_interactioncount_post(
							p_outcome_id=>l_outcome_id,
							p_result_id=>l_result_id,
							p_reason_id=>l_reason_id,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

	IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'GET_INTERACTIONCOUNT', 'B', 'C') THEN
		JTF_IH_PUB_CUHK.get_interactioncount_post(
							p_outcome_id=>l_outcome_id,
							p_result_id=>l_result_id,
							p_reason_id=>l_reason_id,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
  ( p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
  ( p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get
  ( p_count       => x_msg_count,
    p_data  => x_msg_data );
  x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Get_InteractionCount;
--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	Jean Zhu	11-JAN-2000	INITIAL VERSION
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--	James Baldo Jr.	02-MAY-2000	Fix for Start_Date_Time and End_Date_Time bugdb # 1286036
--	James Baldo Jr. 27-JUL-2000	Fix for Start_Date_Time initialization when G_MISS_DATE
--					for bugdb # 1339916.
--  Igor Aleshin    12-MAY-2001  Added request for the column Script_Trans_ID in the JTF_IH_ACTIVITIES.
--  Igor Aleshin    21-DEC-2001 Fix for bugdb - 2153913 - PREVENT G_MISS_DATE VALUE FROM BEING
--            WRITTEN TO THE END_DATE_TIME VALUE.
--  Igor Aleshin    18-APR-2001 Fix for bugdb 2323210 - 1157.6RI:API
--            ERR:JTF_IH_PUB.CLOSE_INTERACTION:WHEN DISAGREE WITH OKC IN IBE
--  Igor Aleshin    24-FEB-2003 Fixed bug# 2817083 - Error loggin interactions
--  Igor Aleshin    18-JUN-2003 Enh# 1846960 - REQUIRE CONTACT NAME OF ORGANISATION IN INTERACTION HISTORY
--
--

 PROCEDURE Open_Interaction
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id			IN	NUMBER 	 DEFAULT NULL,
	p_resp_id			IN	NUMBER DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER DEFAULT NULL,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_interaction_rec		IN	INTERACTION_REC_TYPE,
	x_interaction_id		OUT NOCOPY	NUMBER
)
AS
		l_api_name   		CONSTANT VARCHAR2(30) := 'Open_Interaction';
		l_api_version      		CONSTANT NUMBER       := 1.0;
		l_api_name_full    		CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		l_return_status    		VARCHAR2(1);
		--l_interaction_id		NUMBER;
		--l_start_date_time		DATE;
  -- 20153913
		--l_end_date_time		    DATE;
		l_active			VARCHAR2(1);
		--l_duration			NUMBER := NULL;
		--l_productive_time_amount	NUMBER := NULL;
		l_test_msg			VARCHAR2(1996);
		l_return_code			VARCHAR2(1);
		l_data				VARCHAR2(2000);
		l_count				NUMBER;
		l_interaction_rec		INTERACTION_REC_TYPE;
		BEGIN
                        -- local variables initialization to remove GSCC warnings
                        l_active := 'Y';

			-- Standard start of API savepoint
			SAVEPOINT open_interaction_pub;

			-- Preprocessing Call
			l_interaction_rec := p_interaction_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'OPEN_INTERACTION', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.open_interaction_pre(p_interaction_rec=>l_interaction_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'OPEN_INTERACTION', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.open_interaction_pre(p_interaction_rec=>l_interaction_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
		x_return_status := fnd_api.g_ret_sts_error;
		jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full,
			to_char(p_interaction_rec.interaction_id),'fnd_api.compatible_api_call');

		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--l_test_msg := '1';
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Open_Interaction');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;

		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Open_Interaction');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Interaction_Record
		(	p_api_name      => l_api_name_full,
			--p_int_val_rec   => p_interaction_rec,
			p_int_val_rec   => l_interaction_rec,
			p_resp_appl_id  => p_resp_appl_id,
			p_resp_id       => p_resp_id,
			x_return_status       => l_return_status
		);

		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;

		-- DBMS_OUTPUT.PUT_LINE('PAST Validate_Interaction_Record in JTF_IH_PUB.Open_Interaction');
		-- assign the end_date_time
		IF (p_interaction_rec.end_date_time <> fnd_api.g_miss_date) AND (p_interaction_rec.end_date_time IS NOT NULL) THEN
			  --l_end_date_time := p_interaction_rec.end_date_time;
			  l_interaction_rec.end_date_time := p_interaction_rec.end_date_time;
                ELSE
                          --l_end_date_time := NULL;
                          l_interaction_rec.end_date_time := NULL;
		END IF;

		-- assign the start_date_time
		IF((p_interaction_rec.start_date_time IS NOT NULL) AND (p_interaction_rec.start_date_time <> fnd_api.g_miss_date))THEN
			--l_start_date_time := p_interaction_rec.start_date_time;
			l_interaction_rec.start_date_time := p_interaction_rec.start_date_time;
		ELSE
			--l_start_date_time := SYSDATE;
			l_interaction_rec.start_date_time := SYSDATE;
		END IF;

		Validate_StartEnd_Date
			(	p_api_name    => l_api_name_full,
				--p_start_date_time   => l_start_date_time,
				p_start_date_time   => l_interaction_rec.start_date_time,
				--p_end_date_time		=> l_end_date_time,
				p_end_date_time	    => l_interaction_rec.end_date_time,
				x_return_status     => l_return_status
			);
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;

  IF (p_interaction_rec.duration <> fnd_api.g_miss_num) AND (p_interaction_rec.duration IS NOT NULL) THEN
			--l_duration := p_interaction_rec.duration;
			l_interaction_rec.duration := p_interaction_rec.duration;
  ELSIF l_interaction_rec.end_date_time IS NULL THEN
      --l_duration := 0;
      l_interaction_rec.duration := 0;
  ELSE
			--l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
			l_interaction_rec.duration := ROUND((l_interaction_rec.end_date_time - l_interaction_rec.start_date_time)*24*60*60);
		END IF;

		-- assign the productive_time_amount
		IF(p_interaction_rec.productive_time_amount IS NOT NULL)
      AND (p_interaction_rec.productive_time_amount <> fnd_api.g_miss_num) THEN
			--l_productive_time_amount := p_interaction_rec.productive_time_amount;
			l_interaction_rec.productive_time_amount := p_interaction_rec.productive_time_amount;
		ELSIF(l_interaction_rec.duration IS NOT NULL) THEN
			IF(p_interaction_rec.non_productive_time_amount IS NOT NULL)
      -- Bug# 2153913
    AND (p_interaction_rec.non_productive_time_amount <> fnd_api.g_miss_num) THEN
				--l_productive_time_amount := l_duration - p_interaction_rec.non_productive_time_amount;
				l_interaction_rec.productive_time_amount := l_interaction_rec.duration - p_interaction_rec.non_productive_time_amount;
				IF(l_interaction_rec.productive_time_amount < 0) THEN
					x_return_status := fnd_api.g_ret_sts_error;
					jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full,
						to_char(p_interaction_rec.non_productive_time_amount),'non_productive_time_amount');
      -- # 1937894
			       fnd_msg_pub.count_and_get
				      (   p_count       => x_msg_count,
				    p_data  => x_msg_data );
       x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
					RETURN;
				END IF;
			ELSE
				--l_productive_time_amount := l_duration;
				l_interaction_rec.productive_time_amount := l_interaction_rec.duration;
			END IF;
		END IF;
		--l_test_msg := '5';

		--SELECT JTF_IH_INTERACTIONS_S1.NextVal into l_interaction_id FROM dual;
		--l_test_msg := '6';

  -- Bug# 2817083
  --l_interaction_id := Get_Interaction_ID(NULL);
  l_interaction_rec.interaction_id := Get_Interaction_ID(NULL);

    -- 08/26/03 mpetrosi B3102306
    -- added cross check of source_code, source_code_id
    validate_source_code(l_api_name_full, l_interaction_rec.source_code_id,
                         l_interaction_rec.source_code, x_return_status);
		IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;

		INSERT INTO jtf_ih_interactions
		(
			 CREATED_BY,
			 REFERENCE_FORM,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 DURATION,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 END_DATE_TIME,
			 FOLLOW_UP_ACTION,
			 NON_PRODUCTIVE_TIME_AMOUNT,
			 RESULT_ID,
			 REASON_ID,
			 START_DATE_TIME,
			 OUTCOME_ID,
			 PREVIEW_TIME_AMOUNT,
			 PRODUCTIVE_TIME_AMOUNT,
			 HANDLER_ID,
			 INTER_INTERACTION_DURATION,
			 INTERACTION_ID,
			 WRAP_UP_TIME_AMOUNT,
			 SCRIPT_ID,
			 PARTY_ID,
			 RESOURCE_ID,
			 OBJECT_ID,
       		 OBJECT_TYPE,
       		 SOURCE_CODE_ID,
       		 SOURCE_CODE,
			 ATTRIBUTE1,
			 ATTRIBUTE2,
			 ATTRIBUTE3,
			 ATTRIBUTE4,
			 ATTRIBUTE5,
			 ATTRIBUTE6,
			 ATTRIBUTE7,
			 ATTRIBUTE8,
			 ATTRIBUTE9,
			 ATTRIBUTE10,
			 ATTRIBUTE11,
			 ATTRIBUTE12,
			 ATTRIBUTE13,
			 ATTRIBUTE14,
			 ATTRIBUTE15,
			 ATTRIBUTE_CATEGORY,
			 ACTIVE,
			 TOUCHPOINT1_TYPE,
			 TOUCHPOINT2_TYPE,
       METHOD_CODE,
       PRIMARY_PARTY_ID,
       CONTACT_REL_PARTY_ID,
       CONTACT_PARTY_ID
			)
			VALUES
			(
			 p_user_id,
			 decode(p_interaction_rec.reference_form, fnd_api.g_miss_char, null, p_interaction_rec.reference_form),
			 Sysdate,
			 p_user_id,
			 --l_duration,
			 l_interaction_rec.duration,
			 Sysdate,
			 p_login_id,
			 --l_end_date_time,
			 l_interaction_rec.end_date_time,
			 decode( p_interaction_rec.follow_up_action, fnd_api.g_miss_char, null, p_interaction_rec.follow_up_action),
			 decode( p_interaction_rec.non_productive_time_amount, fnd_api.g_miss_num, null, p_interaction_rec.non_productive_time_amount),
			 decode( p_interaction_rec.result_id, fnd_api.g_miss_num, null, p_interaction_rec.result_id),
			 decode( p_interaction_rec.reason_id, fnd_api.g_miss_num, null, p_interaction_rec.reason_id),
			 --l_start_date_time,
			 l_interaction_rec.start_date_time,
			 decode( p_interaction_rec.outcome_id, fnd_api.g_miss_num, null, p_interaction_rec.outcome_id),
			 decode( p_interaction_rec.preview_time_amount, fnd_api.g_miss_num, null, p_interaction_rec.preview_time_amount),
			 --decode(l_productive_time_amount, fnd_api.g_miss_num, null, l_productive_time_amount),
			 decode(l_interaction_rec.productive_time_amount, fnd_api.g_miss_num, null, l_interaction_rec.productive_time_amount),
			 p_interaction_rec.handler_id,
			 decode( p_interaction_rec.inter_interaction_duration, fnd_api.g_miss_num, null, p_interaction_rec.inter_interaction_duration),
			 --l_interaction_id,
			 l_interaction_rec.interaction_id,
			 decode( p_interaction_rec.wrapup_time_amount, fnd_api.g_miss_num, null, p_interaction_rec.wrapup_time_amount),
			 decode( p_interaction_rec.script_id, fnd_api.g_miss_num, null, p_interaction_rec.script_id),
			 p_interaction_rec.party_id,
			 p_interaction_rec.resource_id,
			 decode( p_interaction_rec.object_id, fnd_api.g_miss_num, null, p_interaction_rec.object_id),
			 decode( p_interaction_rec.object_type, fnd_api.g_miss_char, null, p_interaction_rec.object_type),
			 decode( l_interaction_rec.source_code_id, fnd_api.g_miss_num, null, l_interaction_rec.source_code_id),
			 decode( l_interaction_rec.source_code, fnd_api.g_miss_char, null, l_interaction_rec.source_code),
			 decode( p_interaction_rec.attribute1, fnd_api.g_miss_char, null, p_interaction_rec.attribute1),
			 decode( p_interaction_rec.attribute2, fnd_api.g_miss_char, null, p_interaction_rec.attribute2),
			 decode( p_interaction_rec.attribute3, fnd_api.g_miss_char, null, p_interaction_rec.attribute3),
			 decode( p_interaction_rec.attribute4, fnd_api.g_miss_char, null, p_interaction_rec.attribute4),
			 decode( p_interaction_rec.attribute5, fnd_api.g_miss_char, null, p_interaction_rec.attribute5),
			 decode( p_interaction_rec.attribute6, fnd_api.g_miss_char, null, p_interaction_rec.attribute6),
			 decode( p_interaction_rec.attribute7, fnd_api.g_miss_char, null, p_interaction_rec.attribute7),
			 decode( p_interaction_rec.attribute8, fnd_api.g_miss_char, null, p_interaction_rec.attribute8),
			 decode( p_interaction_rec.attribute9, fnd_api.g_miss_char, null, p_interaction_rec.attribute9),
			 decode( p_interaction_rec.attribute10, fnd_api.g_miss_char, null, p_interaction_rec.attribute10),
			 decode( p_interaction_rec.attribute11, fnd_api.g_miss_char, null, p_interaction_rec.attribute11),
			 decode( p_interaction_rec.attribute12, fnd_api.g_miss_char, null, p_interaction_rec.attribute12),
			 decode( p_interaction_rec.attribute13, fnd_api.g_miss_char, null, p_interaction_rec.attribute13),
			 decode( p_interaction_rec.attribute14, fnd_api.g_miss_char, null, p_interaction_rec.attribute14),
			 decode( p_interaction_rec.attribute15, fnd_api.g_miss_char, null, p_interaction_rec.attribute15),
			 decode( p_interaction_rec.attribute_category, fnd_api.g_miss_char, null, p_interaction_rec.attribute_category),
			 l_active,
       decode( p_interaction_rec.touchpoint1_type, fnd_api.g_miss_char, null, p_interaction_rec.touchpoint1_type),
       decode( p_interaction_rec.touchpoint2_type, fnd_api.g_miss_char, null, p_interaction_rec.touchpoint2_type),
       decode( p_interaction_rec.method_code, fnd_api.g_miss_char, null, p_interaction_rec.method_code),
       decode( l_interaction_rec.primary_party_id, fnd_api.g_miss_num, null, l_interaction_rec.primary_party_id),
       decode( l_interaction_rec.contact_rel_party_id, fnd_api.g_miss_num, null, l_interaction_rec.contact_rel_party_id),
       decode( l_interaction_rec.contact_party_id, fnd_api.g_miss_num, null, l_interaction_rec.contact_party_id)
			);
			--l_test_msg := '7';
		-- DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_Interactions in JTF_IH_PUB.Open_Interaction');


     	IF ((p_interaction_rec.parent_id IS NOT NULL) AND (p_interaction_rec.parent_id  <> fnd_api.g_miss_num))	THEN
				INSERT INTO jtf_ih_interaction_inters
				(
					 INTERACT_INTERACTION_ID,
					 INTERACT_INTERACTION_IDRELATES,
					 CREATED_BY,
					 CREATION_DATE,
 					 LAST_UPDATED_BY,
					 LAST_UPDATE_DATE,
					 LAST_UPDATE_LOGIN
				)
				VALUES
				(
					--l_interaction_id,
					l_interaction_rec.interaction_id,
					p_interaction_rec.parent_id,
					p_user_id,
					Sysdate,
					p_user_id,
					Sysdate,
					p_user_id
 				);
		END IF;
		--l_test_msg := '8';
		-- DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_Interaction_inters in JTF_IH_PUB.Open_Interaction');
		--
		-- Set OUT value
		--
		--x_interaction_id := l_interaction_id;
		x_interaction_id := l_interaction_rec.interaction_id;

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'OPEN_INTERACTION', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.open_interaction_post(p_interaction_rec=>l_interaction_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'OPEN_INTERACTION', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.open_interaction_post(p_interaction_rec=>l_interaction_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO open_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO open_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO open_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Open_Interaction;

--
--
-- History
-- -------
--		Author			Date		Description
--		------			----		-----------
--		Jean Zhu		01/11/2000	Initial build
--		James Baldo Jr.		04/11/2000	Fix bug for updating parameters based on G_MISS types
--		James Baldo Jr.		25-APR-2000	User Hooks Customer and Vertical Industry
--		James Baldo Jr.		03-MAY-2000	Fix for bugdb 1286036
--		James Baldo Jr.		05-MAY-2000	Fix start_date_time = sysdate and end_date_time = null bug
--		James Baldo Jr.		06-MAR-2001	Fix touchpoint2_type update issue. Based on bugdb # 1674610
--		James Baldo Jr.		08-MAR-2001	Fix performance issue for multiple updates. Based on bugdb # 1676866
--		and Mike Petrosino
--      Igor Aleshin  18-DEC-2001 Fix for bugdb 2153913
--      Igor Aleshin  20-DEC-2001 Fix for bugdb 2012159 - JTF_IH_PUB.UPDATE_INTERACTION MISSING
--              CODE FOR OBJECT_VERSION_NUMBER PARAMETER.
--      Igor Aleshin  20-MAY-2002 Modyfied duration calculation
--      Igor Aleshin  06-17-2002  Fix for bugdb 2418028 - Close Interaction gives incorrect error
--      Igor Aleshin  06-17-2002  Fix for bugdb 2418345 - Update_Interaction incorrectly
--              handling updates for parent-child interactions
--      Igor Aleshin  11-SEP-2002 Fixed duration overwrite issue
--  	Igor Aleshin  18-JUN-2003 Enh# 1846960 - REQUIRE CONTACT NAME OF ORGANISATION IN INTERACTION HISTORY
--      Igor Aleshin  29-AUG-2003 Bug#3117798 - BR1159: UPDATING SOURCE CODE IN INTERACTIONS GIVES API ERROR.
--

PROCEDURE Update_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL
)
AS
		l_api_name   		CONSTANT VARCHAR2(30) := 'Update_Interaction';
		l_api_version      		CONSTANT NUMBER       := 1.1;
		l_api_name_full    		CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		l_return_status    		VARCHAR2(1);
		l_count				NUMBER;
		l_int_rec			interaction_rec_type;
		l_return_code			VARCHAR2(1);
		l_data				VARCHAR2(2000);
		l_count_hk			NUMBER;
		--l_interaction_rec_hk		INTERACTION_REC_TYPE;
		l_touchpoint1_type		VARCHAR2(30);
		l_touchpoint2_type		VARCHAR2(30);
		l_inter_interaction_duration	NUMBER;
		l_reference_form		VARCHAR2(1000);
		l_follow_up_action		VARCHAR2(80);
		l_non_productive_time_amount	NUMBER;
		l_wrapUp_time_amount		NUMBER;
		l_script_id			NUMBER;
		l_result_id			NUMBER;
		l_reason_id			NUMBER;
		l_object_id			NUMBER;
		l_object_type			VARCHAR2(30);
		l_source_code_id		NUMBER;
		l_source_code			VARCHAR2(100);
		l_parent_id			NUMBER;
		l_attribute1			VARCHAR2(150);
		l_attribute2			VARCHAR2(150);
		l_attribute3			VARCHAR2(150);
		l_attribute4			VARCHAR2(150);
		l_attribute5			VARCHAR2(150);
		l_attribute6			VARCHAR2(150);
		l_attribute7			VARCHAR2(150);
		l_attribute8			VARCHAR2(150);
		l_attribute9			VARCHAR2(150);
		l_attribute10			VARCHAR2(150);
		l_attribute11			VARCHAR2(150);
		l_attribute12			VARCHAR2(150);
		l_attribute13			VARCHAR2(150);
		l_attribute14			VARCHAR2(150);
		l_attribute15			VARCHAR2(150);
		l_attribute_category		VARCHAR2(30);
		l_method_code		   VARCHAR2(30);
  l_object_version NUMBER;
  l_recalc_duration BOOLEAN;
  l_primary_party_id NUMBER;
  l_contact_rel_party_id NUMBER;
  l_contact_party_id NUMBER;
  l_profile_id       VARCHAR2(20);  --profile option id check to update closed interaction
	CURSOR c_Interaction_csr IS
		SELECT *
		FROM 	JTF_IH_INTERACTIONS
		WHERE 	interaction_id = p_interaction_rec.interaction_id
		FOR UPDATE;
	l_Interaction_rec	c_Interaction_csr%ROWTYPE;

	BEGIN
                -- local variables initialization to remove GSCC warning
                l_int_rec := p_interaction_rec;

		-- Standard start of API savepoint
		SAVEPOINT update_interaction_pub;

			-- Preprocessing Call
			--l_interaction_rec_hk := p_interaction_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_INTERACTION', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.update_interaction_pre(
				                     --p_interaction_rec=>l_interaction_rec_hk,
				                     p_interaction_rec=>l_int_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_INTERACTION', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.update_interaction_pre(
				                     --p_interaction_rec=>l_interaction_rec_hk,
				                     p_interaction_rec=>l_int_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
		      RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Update_Interaction');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
			fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
			RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			(	p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Update_Interaction');

		--
		--	Restore existing column values if manadatory paramaters passed are
		--	NULL or of FND_API.G_MISS types
		--

		--
		--	Retrieve necessary parameters via DB Query
		--	N.B., l_count is used after validation
		--

		-- DBMS_OUTPUT.PUT_LINE('party_id: ' || p_interaction_rec.party_id);
		-- DBMS_OUTPUT.PUT_LINE('resource_id: ' || p_interaction_rec.resource_id);
		-- DBMS_OUTPUT.PUT_LINE('handler_id: ' || p_interaction_rec.handler_id);
		-- DBMS_OUTPUT.PUT_LINE('outcome_id: ' || p_interaction_rec.outcome_id);
    -- DBMS_OUTPUT.PUT_LINE('non_productive_time_amount: ' || p_interaction_rec.non_productive_time_amount);
  		l_count := 0;

		OPEN c_Interaction_csr;
		FETCH c_Interaction_csr INTO  l_Interaction_rec;
		IF (c_Interaction_csr%notfound) THEN
			x_return_status := fnd_api.g_ret_sts_error;
			jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, to_char(p_Interaction_rec.interaction_id),
							    'Interaction_id');
      -- # 1937894
			       fnd_msg_pub.count_and_get
				      (   p_count       => x_msg_count,
				    p_data  => x_msg_data );
       x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
			RETURN;
		END IF;

  --
  -- Check if Object_Version_Number was passed
  -- Bug# 2012159
  --
  --IF(p_object_version is null) THEN
		--	    jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, to_char(l_object_version),'The Object_Version_Number set to NULL for interaction');
			    --RAISE fnd_api.g_exc_error;
  --END IF;

		--
		-- Check if Active is set to 'N'
		--
		IF (l_Interaction_rec.active = 'N')  then
		  -- Bug# 4477761 check if profile option is turned on
		  -- If yes then allow update on closed interaction
		  fnd_profile.get('JTF_IH_ALLOW_INT_UPDATE_AFTER_CLOSE',l_profile_id);
		  IF nvl(l_profile_id,'N') <> 'Y' THEN
		    --x_return_status := fnd_api.g_ret_sts_error;
		    --jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, to_char(p_Interaction_rec.interaction_id),'Active set to N for interaction');
		    --Bug# 4477761 new error msg
		    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
		       fnd_message.set_name('JTF', 'JTF_IH_INT_UPDATE_NOT_ALLOW');
		       fnd_message.set_token('INT_ID', to_char(p_Interaction_rec.interaction_id));
		       fnd_msg_pub.add;
		    END IF;
		    RAISE fnd_api.g_exc_error;
         	  END IF;
		END IF;
		--
		--	Check mandatory parameters to determine if their update paramater
		--	is null or of a FND_API.G_MISS type then set to existing DB record
		--	column value if needed.
		--

		--
		-- Check if party_id requies updating
		--

		IF (p_interaction_rec.party_id = fnd_api.g_miss_num) OR (p_interaction_rec.party_id IS NULL)  then
			l_int_rec.party_id := l_interaction_rec.party_id;
		ELSE
			l_int_rec.party_id := p_interaction_rec.party_id;
		END IF;


		--
		-- Check if resource_id requies updating
		--

		IF (p_interaction_rec.resource_id = fnd_api.g_miss_num) OR (p_interaction_rec.resource_id IS NULL)  then
			l_int_rec.resource_id := l_interaction_rec.resource_id;
		ELSE
			l_int_rec.resource_id := p_interaction_rec.resource_id;
		END IF;

		--
		-- Check if handler_id requies updating
		--

		IF (p_interaction_rec.handler_id = fnd_api.g_miss_num) OR (p_interaction_rec.handler_id IS NULL)  then
			l_int_rec.handler_id := l_interaction_rec.handler_id;
		ELSE
			l_int_rec.handler_id := p_interaction_rec.handler_id;
		END IF;

		--
		-- Check if outcome_id requies updating
		--

		--IF (p_interaction_rec.outcome_id = fnd_api.g_miss_num) OR (p_interaction_rec.outcome_id IS NULL)  then
		IF (p_interaction_rec.outcome_id = fnd_api.g_miss_num) then
			l_int_rec.outcome_id := l_interaction_rec.outcome_id;
		ELSE
			l_int_rec.outcome_id := p_interaction_rec.outcome_id;
		END IF;

		--
		-- Check if touchpoint1_type requies updating
		--

		--IF (p_interaction_rec.touchpoint1_type = fnd_api.g_miss_char) OR (p_interaction_rec.touchpoint1_type IS NULL)  then
		IF (p_interaction_rec.touchpoint1_type = fnd_api.g_miss_char) then
			l_int_rec.touchpoint1_type := l_interaction_rec.touchpoint1_type;
		ELSE
			l_int_rec.touchpoint1_type := p_interaction_rec.touchpoint1_type;
		END IF;

		--
		-- Check if touchpoint2_type requies updating
		--

		--IF (p_interaction_rec.touchpoint2_type = fnd_api.g_miss_char) OR (p_interaction_rec.touchpoint2_type IS NULL)  then
		IF (p_interaction_rec.touchpoint2_type = fnd_api.g_miss_char) then
			l_int_rec.touchpoint2_type := l_interaction_rec.touchpoint2_type;
		ELSE
			l_int_rec.touchpoint2_type := p_interaction_rec.touchpoint2_type;
		END IF;

		--
		-- Check if reference_form requies updating
		--

		--IF (p_interaction_rec.reference_form = fnd_api.g_miss_char) OR (p_interaction_rec.reference_form IS NULL)  then
		IF (p_interaction_rec.reference_form = fnd_api.g_miss_char) then
			l_int_rec.reference_form := l_interaction_rec.reference_form;
		ELSE
			l_int_rec.reference_form := p_interaction_rec.reference_form;
		END IF;

		--
		-- Check if follow_up_action requies updating
		--

		--IF (p_interaction_rec.follow_up_action = fnd_api.g_miss_char) OR (p_interaction_rec.follow_up_action IS NULL)  then
		IF (p_interaction_rec.follow_up_action = fnd_api.g_miss_char) then
			l_int_rec.follow_up_action := l_interaction_rec.follow_up_action;
		ELSE
			l_int_rec.follow_up_action := p_interaction_rec.follow_up_action;
		END IF;

		--
		-- Check if previw_time_amount requies updating
		--

		--IF (p_interaction_rec.preview_time_amount = fnd_api.g_miss_num) OR (p_interaction_rec.preview_time_amount IS NULL)  then
		IF (p_interaction_rec.preview_time_amount = fnd_api.g_miss_num) then
			l_int_rec.preview_time_amount := l_interaction_rec.preview_time_amount;
		ELSE
			l_int_rec.preview_time_amount := p_interaction_rec.preview_time_amount;
		END IF;

  -- Added by IALeshin 20-MAY-2002
		l_recalc_duration := FALSE;
		IF ((p_interaction_rec.end_date_time <> fnd_api.g_miss_date) AND (p_interaction_rec.end_date_time IS NOT NULL)) then
			l_int_rec.end_date_time := p_interaction_rec.end_date_time;
			-- duration may need to be recalculated based on the new value - RDD
			l_recalc_duration := TRUE;
		ELSE
			l_int_rec.end_date_time := l_interaction_rec.end_date_time;
		END IF;

  -- Added by IALeshin 20-MAY-2002
		--
		-- Check if start_date_time requies updating
		--
		IF ((p_interaction_rec.start_date_time = fnd_api.g_miss_date) OR (p_interaction_rec.start_date_time IS NULL)) then
			l_int_rec.start_date_time := l_interaction_rec.start_date_time;
		ELSE
			l_int_rec.start_date_time := p_interaction_rec.start_date_time;
			-- duration may need to be recalculated based on the new value - RDD
			l_recalc_duration := TRUE;
		END IF;

    		Validate_StartEnd_Date
				(	p_api_name    	=> l_api_name_full,
					p_start_date_time   	=> l_int_rec.start_date_time,
					p_end_date_time		    => l_int_rec.end_date_time,
					x_return_status     	=> l_return_status
				);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;

		-- Determine if duration recalc can be done.  We require start and end date. - RDD
		IF l_recalc_duration = TRUE THEN
			IF l_int_rec.end_date_time IS NULL THEN
				l_recalc_duration := FALSE;
			END IF;
		END IF;


		IF p_interaction_rec.duration <> fnd_api.g_miss_num AND p_interaction_rec.duration IS NOT NULL THEN
			l_int_rec.duration := p_interaction_rec.duration;
		ELSIF l_recalc_duration = TRUE THEN
			l_int_rec.duration := ROUND((l_int_rec.end_date_time - l_int_rec.start_date_time)*24*60*60);
		ELSE
			l_int_rec.duration := l_interaction_rec.duration;
		END IF;
  --

		--
		-- Check if inter_interaction_duration requies updating
		--

		--IF (p_interaction_rec.inter_interaction_duration = fnd_api.g_miss_num) OR (p_interaction_rec.inter_interaction_duration IS NULL)  then
		IF (p_interaction_rec.inter_interaction_duration = fnd_api.g_miss_num) then
			l_int_rec.inter_interaction_duration := l_interaction_rec.inter_interaction_duration;
		ELSE
			l_int_rec.inter_interaction_duration := p_interaction_rec.inter_interaction_duration;
		END IF;



		--
		-- Check if non_productive_time_amount requies updating
		--
		--IF (p_interaction_rec.non_productive_time_amount = fnd_api.g_miss_num) OR (p_interaction_rec.non_productive_time_amount IS NULL)  then
		IF (p_interaction_rec.non_productive_time_amount = fnd_api.g_miss_num) then
			l_int_rec.non_productive_time_amount := l_interaction_rec.non_productive_time_amount;
		ELSE
			l_int_rec.non_productive_time_amount := p_interaction_rec.non_productive_time_amount;
		END IF;

		--
		-- Check if productive_time_amount requies updating
		--
		-- IF (p_interaction_rec.productive_time_amount = fnd_api.g_miss_num) OR (p_interaction_rec.productive_time_amount IS NULL)  then
		IF (p_interaction_rec.productive_time_amount = fnd_api.g_miss_num) then
			l_int_rec.productive_time_amount := l_interaction_rec.productive_time_amount;
		ELSE
			l_int_rec.productive_time_amount := p_interaction_rec.productive_time_amount;
		END IF;

		--
		-- Check if wrapUp_time_amount requies updating
		--

		--IF (p_interaction_rec.wrapUp_time_amount = fnd_api.g_miss_num) OR (p_interaction_rec.wrapUp_time_amount IS NULL)  then
		IF (p_interaction_rec.wrapUp_time_amount = fnd_api.g_miss_num) then
			l_int_rec.wrapUp_time_amount := l_interaction_rec.wrap_Up_time_amount;
		ELSE
      l_int_rec.wrapUp_time_amount := p_interaction_rec.wrapUp_time_amount;
		END IF;

		--
		-- Check if script_id requies updating
		--
		--IF (p_interaction_rec.script_id = fnd_api.g_miss_num) OR (p_interaction_rec.script_id IS NULL)  then
		IF (p_interaction_rec.script_id = fnd_api.g_miss_num) then
			l_int_rec.script_id := l_interaction_rec.script_id;
		ELSE
			l_int_rec.script_id := p_interaction_rec.script_id;
		END IF;

		--
		-- Check if result_id requies updating
		--
		--IF (p_interaction_rec.result_id = fnd_api.g_miss_num) OR (p_interaction_rec.result_id IS NULL)  then
		IF (p_interaction_rec.result_id = fnd_api.g_miss_num) then
			l_int_rec.result_id := l_interaction_rec.result_id;
		ELSE
			l_int_rec.result_id := p_interaction_rec.result_id;
		END IF;

		--
		-- Check if reason_id requies updating
		--
		--IF (p_interaction_rec.reason_id = fnd_api.g_miss_num) OR (p_interaction_rec.reason_id IS NULL)  then
		IF (p_interaction_rec.reason_id = fnd_api.g_miss_num) then
			l_int_rec.reason_id := l_interaction_rec.reason_id;
		ELSE
			l_int_rec.reason_id := p_interaction_rec.reason_id;
		END IF;

		--
		-- Check if object_id requies updating
		--
		-- IF (p_interaction_rec.object_id = fnd_api.g_miss_num) OR (p_interaction_rec.object_id IS NULL)  then
		IF (p_interaction_rec.object_id = fnd_api.g_miss_num) then
			l_int_rec.object_id := l_interaction_rec.object_id;
		ELSE
			l_int_rec.object_id := p_interaction_rec.object_id;
		END IF;

		--
		-- Check if object_type requies updating
		--
		-- IF (p_interaction_rec.object_type = fnd_api.g_miss_char) OR (p_interaction_rec.object_type IS NULL)  then
		IF (p_interaction_rec.object_type = fnd_api.g_miss_char) then
			l_int_rec.object_type := l_interaction_rec.object_type;
		ELSE
			l_int_rec.object_type := p_interaction_rec.object_type;
		END IF;

		--
		-- Check if source_code_id and source_code requies updating
		--

        IF(p_interaction_rec.source_code_id = fnd_api.g_miss_num)
            AND (p_interaction_rec.source_code = fnd_api.g_miss_char) THEN
			l_int_rec.source_code_id := l_interaction_rec.source_code_id;
			l_int_rec.source_code := l_interaction_rec.source_code;
        ELSE
			l_int_rec.source_code_id := p_interaction_rec.source_code_id;
			l_int_rec.source_code := p_interaction_rec.source_code;
        END IF;
		--
		-- Check if parent_id requies updating
		--
    		IF ((p_interaction_rec.parent_id IS NOT NULL) AND (p_interaction_rec.parent_id  <> fnd_api.g_miss_num))	THEN
     			l_count := 0;
			SELECT count(*) into l_count
			 FROM jtf_ih_interaction_inters
			     WHERE interact_interaction_id = p_interaction_rec.interaction_id;

       -- Bug# 2418345
			 --    WHERE interact_interaction_id = p_interaction_rec.interaction_id and
			 --       interact_interaction_idrelates = p_interaction_rec.parent_id;

      		IF (l_count = 0) THEN
				  INSERT INTO jtf_ih_interaction_inters
				  (
					       INTERACT_INTERACTION_IDRELATES,
					       INTERACT_INTERACTION_ID,
					       CREATED_BY,
					       CREATION_DATE,
 					       LAST_UPDATED_BY,
					       LAST_UPDATE_DATE,
					       LAST_UPDATE_LOGIN
				  )
				  VALUES
				  (
					       p_interaction_rec.parent_id,
					       p_interaction_rec.interaction_id,
					       p_user_id,
					       Sysdate,
					       p_user_id,
					       Sysdate,
					       p_user_id
 				       );
				       l_int_rec.parent_id := p_interaction_rec.parent_id;
       -- Bug# 2418345
         ELSE
      UPDATE jtf_ih_interaction_inters SET
         INTERACT_INTERACTION_IDRELATES = p_interaction_rec.parent_id,
 					       LAST_UPDATED_BY = p_user_id ,
					       LAST_UPDATE_DATE = SYSDATE,
					       LAST_UPDATE_LOGIN = p_user_id
         WHERE interact_interaction_id = p_interaction_rec.interaction_id;
			   END IF;
		    END IF;

		--
		-- Check if attribute1 requies updating
		--
		--IF (p_interaction_rec.attribute1 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute1 IS NULL)  then
		IF (p_interaction_rec.attribute1 = fnd_api.g_miss_char) then
			l_int_rec.attribute1 := l_interaction_rec.attribute1;
		ELSE
			l_int_rec.attribute1 := p_interaction_rec.attribute1;
		END IF;

		--
		-- Check if attribute2 requies updating
		--

		--IF (p_interaction_rec.attribute2 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute2 IS NULL)  then
		IF (p_interaction_rec.attribute2 = fnd_api.g_miss_char) then
			l_int_rec.attribute2 := l_interaction_rec.attribute2;
		ELSE
			l_int_rec.attribute2 := p_interaction_rec.attribute2;
		END IF;

		--
		-- Check if attribute3 requies updating
		--

		--IF (p_interaction_rec.attribute3 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute3 IS NULL)  then
		IF (p_interaction_rec.attribute3 = fnd_api.g_miss_char) then
			l_int_rec.attribute3 := l_interaction_rec.attribute3;
		ELSE
			l_int_rec.attribute3 := p_interaction_rec.attribute3;
		END IF;

		--
		-- Check if attribute4 requies updating
		--

		-- IF (p_interaction_rec.attribute4 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute4 IS NULL)  then
		IF (p_interaction_rec.attribute4 = fnd_api.g_miss_char) then
			l_int_rec.attribute4 := l_interaction_rec.attribute4;
		ELSE
			l_int_rec.attribute4 := p_interaction_rec.attribute4;
		END IF;

		--
		-- Check if attribute5 requies updating
		--
		--IF (p_interaction_rec.attribute5 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute5 IS NULL)  then
		IF (p_interaction_rec.attribute5 = fnd_api.g_miss_char) then
			l_int_rec.attribute5 := l_interaction_rec.attribute5;
		ELSE
			l_int_rec.attribute5 := p_interaction_rec.attribute5;
		END IF;

		--
		-- Check if attribute6 requies updating
		--

		--IF (p_interaction_rec.attribute6 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute6 IS NULL)  then
		IF (p_interaction_rec.attribute6 = fnd_api.g_miss_char) then
			l_int_rec.attribute6 := l_interaction_rec.attribute6;
		ELSE
			l_int_rec.attribute6 := p_interaction_rec.attribute6;
		END IF;

		--
		-- Check if attribute7 requies updating
		--

		--IF (p_interaction_rec.attribute7 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute7 IS NULL)  then
		IF (p_interaction_rec.attribute7 = fnd_api.g_miss_char) then
			l_int_rec.attribute7 := l_interaction_rec.attribute7;
			--l_int_rec.attribute7 := l_interaction_rec.attribute7;
		ELSE
			l_int_rec.attribute7 := p_interaction_rec.attribute7;
		END IF;

		--
		-- Check if attribute8 requies updating
		--

		--IF (p_interaction_rec.attribute8 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute8 IS NULL)  then
		IF (p_interaction_rec.attribute8 = fnd_api.g_miss_char) then
			l_int_rec.attribute8 := l_interaction_rec.attribute8;
			--l_int_rec.attribute8 := l_interaction_rec.attribute8;
		ELSE
			l_int_rec.attribute8 := p_interaction_rec.attribute8;
		END IF;

		--
		-- Check if attribute9 requies updating
		--

		--IF (p_interaction_rec.attribute9 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute9 IS NULL)  then
		IF (p_interaction_rec.attribute9 = fnd_api.g_miss_char) then
			l_int_rec.attribute9 := l_interaction_rec.attribute1;
			--l_int_rec.attribute9 := l_interaction_rec.attribute9;
		ELSE
			l_int_rec.attribute9 := p_interaction_rec.attribute9;
		END IF;

		--
		-- Check if attribute10 requies updating
		--

		--IF (p_interaction_rec.attribute10 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute10 IS NULL)  then
		IF (p_interaction_rec.attribute10 = fnd_api.g_miss_char) then
			l_int_rec.attribute10 := l_interaction_rec.attribute10;
			--l_int_rec.attribute10 := l_interaction_rec.attribute10;
		ELSE
			l_int_rec.attribute10 := p_interaction_rec.attribute10;
		END IF;

		--
		-- Check if attribute11 requies updating
		--

		--IF (p_interaction_rec.attribute11 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute11 IS NULL)  then
		IF (p_interaction_rec.attribute11 = fnd_api.g_miss_char) then
			l_int_rec.attribute11 := l_interaction_rec.attribute11;
			--l_int_rec.attribute11 := l_interaction_rec.attribute11;
		ELSE
			l_int_rec.attribute11 := p_interaction_rec.attribute11;
		END IF;

		--
		-- Check if attribute12 requies updating
		--

		--IF (p_interaction_rec.attribute12 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute12 IS NULL)  then
		IF (p_interaction_rec.attribute12 = fnd_api.g_miss_char) then
			l_int_rec.attribute12 := l_interaction_rec.attribute12;
			--l_int_rec.attribute12 := l_interaction_rec.attribute12;
		ELSE
			l_int_rec.attribute12 := p_interaction_rec.attribute12;
		END IF;

		--
		-- Check if attribute13 requies updating
		--
		--IF (p_interaction_rec.attribute13 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute13 IS NULL)  then
		IF (p_interaction_rec.attribute13 = fnd_api.g_miss_char) then
			l_int_rec.attribute13 := l_interaction_rec.attribute13;
			--l_int_rec.attribute13 := l_interaction_rec.attribute13;
		ELSE
			l_int_rec.attribute13 := p_interaction_rec.attribute13;
		END IF;

		--
		-- Check if attribute14 requies updating
		--

		--IF (p_interaction_rec.attribute14 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute14 IS NULL)  then
		IF (p_interaction_rec.attribute14 = fnd_api.g_miss_char) then
			l_int_rec.attribute14 := l_interaction_rec.attribute14;
			--l_int_rec.attribute14 := l_interaction_rec.attribute14;
		ELSE
			l_int_rec.attribute14 := p_interaction_rec.attribute14;
		END IF;

		--
		-- Check if attribute15 requies updating
		--
		--IF (p_interaction_rec.attribute15 = fnd_api.g_miss_char) OR (p_interaction_rec.attribute15 IS NULL)  then
		IF (p_interaction_rec.attribute15 = fnd_api.g_miss_char) then
			l_int_rec.attribute15 := l_interaction_rec.attribute15;
			--l_int_rec.attribute15 := l_interaction_rec.attribute15;
		ELSE
			l_int_rec.attribute15 := p_interaction_rec.attribute15;
		END IF;

		--
		-- Check if attribute_category requies updating
		--
		--IF (p_interaction_rec.attribute_category = fnd_api.g_miss_char) OR (p_interaction_rec.attribute_category IS NULL)  then
		IF (p_interaction_rec.attribute_category = fnd_api.g_miss_char) then
			l_int_rec.attribute_category := l_interaction_rec.attribute_category;
			--l_int_rec.attribute_category := l_interaction_rec.attribute_category;
		ELSE
			l_int_rec.attribute_category := p_interaction_rec.attribute_category;
		END IF;

		IF (p_interaction_rec.method_code = fnd_api.g_miss_char) then
			l_int_rec.method_code := l_interaction_rec.method_code;
		ELSE
			l_int_rec.method_code := p_interaction_rec.method_code;
		END IF;
  IF p_api_version = 1.0 THEN
		  l_int_rec.primary_party_id := NULL;
		  l_int_rec.contact_rel_party_id := NULL;
		  l_int_rec.contact_party_id := NULL;
  ELSE
		  IF (p_interaction_rec.primary_party_id = fnd_api.g_miss_num) then
			 l_int_rec.primary_party_id := l_interaction_rec.primary_party_id;
		  ELSE
			l_int_rec.primary_party_id := p_interaction_rec.primary_party_id;
		  END IF;

		  IF (p_interaction_rec.contact_rel_party_id = fnd_api.g_miss_num) then
			l_int_rec.contact_rel_party_id := l_interaction_rec.contact_rel_party_id;
		  ELSE
			l_int_rec.contact_rel_party_id := p_interaction_rec.contact_rel_party_id;
		  END IF;
		  IF (p_interaction_rec.contact_party_id = fnd_api.g_miss_num) then
			l_int_rec.contact_party_id := l_interaction_rec.contact_party_id;
		  ELSE
			l_int_rec.contact_party_id := p_interaction_rec.contact_party_id;
		  END IF;
  END IF;

		-- DBMS_OUTPUT.PUT_LINE('party_id: ' || l_interaction_rec.party_id);
		-- DBMS_OUTPUT.PUT_LINE('resource_id: ' || l_interaction_rec.resource_id);
		-- DBMS_OUTPUT.PUT_LINE('handler_id: ' || l_interaction_rec.handler_id);
		-- DBMS_OUTPUT.PUT_LINE('outcome_id: ' || l_interaction_rec.outcome_id);
		-- DBMS_OUTPUT.PUT_LINE('non_productive_time_amount: ' || l_interaction_rec.non_productive_time_amount);

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--

		Validate_Interaction_Record
		(	p_api_name      => l_api_name_full,
			p_int_val_rec   => l_int_rec,
			p_resp_appl_id  => p_resp_appl_id,
			p_resp_id       => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST Validate_Interaction_Record in JTF_IH_PUB.Update_Interaction');

    -- 08/26/03 mpetrosi B3102306
    -- added cross check of source_code, source_code_id
    validate_source_code(l_api_name_full,l_int_rec.source_code_id, l_int_rec.source_code, l_return_status);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;

		--
		-- Update table JTF_IH_INTERACTIONS
		--
		IF (p_interaction_rec.interaction_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'interaction_id');
				RAISE fnd_api.g_exc_error;
		ELSE
  			l_count := 0;
			SELECT count(*) into l_count
			FROM jtf_ih_interactions
			WHERE interaction_id = p_interaction_rec.interaction_id;
			IF(l_count <> 1) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_interaction_rec.interaction_id),
					    'interaction_id');
      -- # 1937894
			       fnd_msg_pub.count_and_get
				      (   p_count       => x_msg_count,
				    p_data  => x_msg_data );
       x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
				RETURN;
			ELSE
				UPDATE JTF_IH_INTERACTIONS
				SET
			 		REFERENCE_FORM			= l_int_rec.reference_form,
					LAST_UPDATED_BY			= p_user_id,
					DURATION			= l_int_rec.duration,
					LAST_UPDATE_DATE		= sysdate,
					LAST_UPDATE_LOGIN		= p_login_id,
					END_DATE_TIME			= l_int_rec.end_date_time,
					FOLLOW_UP_ACTION		= l_int_rec.follow_up_action,
					NON_PRODUCTIVE_TIME_AMOUNT	= l_int_rec.non_productive_time_amount,
					RESULT_ID			= l_int_rec.result_id,
					REASON_ID			= l_int_rec.reason_id,
					START_DATE_TIME			= l_int_rec.start_date_time,
					OUTCOME_ID			= decode( l_int_rec.outcome_id, fnd_api.g_miss_num, null, l_int_rec.outcome_id),
					PREVIEW_TIME_AMOUNT		= l_int_rec.preview_time_amount,
					PRODUCTIVE_TIME_AMOUNT		= l_int_rec.productive_time_amount,
					HANDLER_ID			= l_int_rec.handler_id,
					INTER_INTERACTION_DURATION	= l_int_rec.inter_interaction_duration,
					WRAP_UP_TIME_AMOUNT		= l_int_rec.wrapUp_time_amount,
					SCRIPT_ID			= l_int_rec.script_id,
					PARTY_ID			= l_int_rec.party_id,
					RESOURCE_ID			= l_int_rec.resource_id,
					OBJECT_ID			= l_int_rec.object_id,
		       		OBJECT_TYPE			= l_int_rec.object_type,
		       		SOURCE_CODE_ID		= decode(l_int_rec.source_code_id,fnd_api.g_miss_num,NULL,l_int_rec.source_code_id),
		       		SOURCE_CODE			= decode(l_int_rec.source_code,fnd_api.g_miss_char,NULL,l_int_rec.source_code),
					ATTRIBUTE1			= l_int_rec.attribute1,
					ATTRIBUTE2			= l_int_rec.attribute2,
					ATTRIBUTE3			= l_int_rec.attribute3,
					ATTRIBUTE4			= l_int_rec.attribute4,
					ATTRIBUTE5			= l_int_rec.attribute5,
					ATTRIBUTE6			= l_int_rec.attribute6,
					ATTRIBUTE7			= l_int_rec.attribute7,
					ATTRIBUTE8			= l_int_rec.attribute8,
					ATTRIBUTE9			= l_int_rec.attribute9,
					ATTRIBUTE10			= l_int_rec.attribute10,
					ATTRIBUTE11			= l_int_rec.attribute11,
					ATTRIBUTE12			= l_int_rec.attribute12,
					ATTRIBUTE13			= l_int_rec.attribute13,
					ATTRIBUTE14			= l_int_rec.attribute14,
					ATTRIBUTE_CATEGORY	= l_int_rec.attribute_category,
					TOUCHPOINT1_TYPE	= l_int_rec.touchpoint1_type,
					TOUCHPOINT2_TYPE	= l_int_rec.touchpoint2_type,
        METHOD_CODE   = l_int_rec.method_code,
        primary_party_id    = l_int_rec.primary_party_id,
        contact_rel_party_id = l_int_rec.contact_rel_party_id,
        contact_party_id    = l_int_rec.contact_party_id
				WHERE CURRENT OF c_Interaction_csr;
				--
				-- Close Cursor
				--
				Close c_Interaction_csr;
				--
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST update table jtf_ih_interactions in JTF_IH_PUB.Update_Interaction');

		-- DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_Interaction_inters in JTF_IH_PUB.Update_Interaction');

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_INTERACTION', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.update_interaction_post(
				                     --p_interaction_rec=>l_interaction_rec_hk,
				                     p_interaction_rec=>l_int_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_INTERACTION', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.update_interaction_post(
				                     --p_interaction_rec=>l_interaction_rec_hk,
				                     p_interaction_rec=>l_int_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );

		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO update_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO update_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO update_interaction_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Update_Interaction;

--
--
-- History
-- -------
--		Author			Date		Description
--		------			----		-----------
--		Jean Zhu		01/11/2000	Initial build
--		James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--		James Baldo Jr.	03-MAY-2000	Fix for bugdb 1286036 and 1288344
--		James Baldo Jr.	24-MAY-2000	Fix for bugdb 1311442 - closing interaction without outcome set
--		James Baldo Jr.	27-JUL-2000	Fix for bugdb 1314647 - calculation for duration
--      Igor Aleshin    04-JAN-2002	Fix for bugdb 2167904 - g_miss values issue
--      Igor Aleshin    25-MAR-2002 Fix for bugdb 2281489 - null message data with 'E' status
--      Igor Aleshin    01-APR-2002 Fix for bugdb 1937894 - interaction history apis are raising
--          exceptions without error message
--      Igor Aleshin    06-17-2002 Fix for bugdb 2418028 - Close Interaction gives incorrect error
--      Igor Aleshin    11-SEP-2002 Fixed bug# 2560551 - TST1158.8: FUNC: DEBUG - ALL INTERACTIONS
--          DISPLAYS INTERACTION DURATION AS 0
--  vekrishn        27-JUL-2004 Perf Fix for literal Usage
--
--

PROCEDURE Close_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type,
    p_object_version IN NUMBER DEFAULT NULL
)
AS
		l_api_name   	CONSTANT VARCHAR2(30) := 'Close_Interaction';
		l_api_version      	CONSTANT NUMBER       := 1.1;
		l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		l_return_status    	VARCHAR2(1);
		--l_outcome_id		NUMBER := NULL;
		--l_end_date_time		DATE := NULL;
		--l_start_date_time	DATE := NULL;
		--l_duration		NUMBER := 0;
		l_action_item_id	NUMBER := NULL;
		l_count			NUMBER := 0;
		l_return_code		VARCHAR2(1);
		l_data			VARCHAR2(2000);
		l_count_hk		NUMBER;
		l_interaction_rec	INTERACTION_REC_TYPE;

  -- Bug# 2560511
		la_outcome_id		NUMBER := NULL;
		la_end_date_time		DATE := NULL;
		la_start_date_time	DATE := NULL;
		la_duration		NUMBER := 0;

  -- Bug# 3779487
 	 	msg_code		VARCHAR2(50);
		la_out_act_list	jtf_ih_core_util_pvt.param_tbl_type;

  -- Perf fix for literal Usage
  l_active_perf            VARCHAR2(1);

		CURSOR	l_activity_id_c IS
		SELECT activity_id FROM jtf_ih_activities
		WHERE interaction_id = p_interaction_rec.interaction_id;
	BEGIN
		SAVEPOINT close_interaction_pub1;

   -- Perf variables
   l_active_perf := 'N';

		-- Preprocessing Call
		l_interaction_rec := p_interaction_rec;

		IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_INTERACTION', 'B', 'C') THEN
			JTF_IH_PUB_CUHK.close_interaction_pre(p_interaction_rec=>l_interaction_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
			IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

		IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_INTERACTION', 'B', 'V') THEN
			JTF_IH_PUB_VUHK.close_interaction_pre(p_interaction_rec=>l_interaction_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
			IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Close_Interaction');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
			fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Close_Interaction');
   	  SELECT count(*) into l_count
    FROM jtf_ih_activities
    WHERE interaction_id = p_interaction_rec.interaction_id;
		-- DBMS_OUTPUT.PUT_LINE('lcount = ' || l_count);
    IF (l_count <= 0) THEN
   	 x_return_status := fnd_api.g_ret_sts_error;
		 -- DBMS_OUTPUT.PUT_LINE('x_return_status = ' || x_return_status);
   -- Bug# 1937894
--     jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, to_char(p_interaction_rec.interaction_id),
--					    'activity_id');
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success) THEN
      fnd_message.set_name('JTF', 'JTF_IH_NO_ACTIVITY');
      fnd_message.set_token('API_NAME', l_api_name);
      fnd_msg_pub.add;
     END IF;

		 -- DBMS_OUTPUT.PUT_LINE('Yes');
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				  p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');

	   RETURN;
		END IF;

		--
		--
		-- Update interaction
		--
		Update_Interaction
		(	p_api_version,
			p_init_msg_list,
			--p_commit,
      -- Bug# 2418028
			FND_API.G_FALSE,
			p_resp_appl_id,
			p_resp_id,
			p_user_id,
			p_login_id,
			x_return_status,
			x_msg_count,
			x_msg_data,
			p_interaction_rec,
      p_object_version);
		IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST Update_Interaction in JTF_IH_PUB.Close_Interaction');

		-- DBMS_OUTPUT.PUT_LINE('PAST validate at least one Activity per Interaction in JTF_IH_PUB.Close_Interaction');
	   	--SELECT outcome_id into l_outcome_id
	   	SELECT outcome_id into l_interaction_rec.outcome_id
	        FROM jtf_ih_interactions
	        WHERE interaction_id = p_interaction_rec.interaction_id;
		IF (l_interaction_rec.outcome_id IS NULL) or (l_interaction_rec.outcome_id = fnd_api.g_miss_num) THEN
			x_return_status := fnd_api.g_ret_sts_error;
		       	jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_interaction_rec.outcome_id),
				    'outcome_id');
      -- # 1937894
      --
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				  p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
			RETURN;
		END IF;

      SELECT end_date_time, start_date_time, duration
      --into l_end_date_time, l_start_date_time, l_duration
      into   l_interaction_rec.end_date_time,
             l_interaction_rec.start_date_time,
             l_interaction_rec.duration
      FROM jtf_ih_interactions
      WHERE interaction_id = p_interaction_rec.interaction_id;

  -- Added by IAleshin 21-MAY-2002
  --
  IF ((p_interaction_rec.start_date_time IS NOT NULL)AND (p_interaction_rec.start_date_time <> fnd_api.g_miss_date)) THEN
      --l_start_date_time := p_interaction_rec.start_date_time;
      l_interaction_rec.start_date_time := p_interaction_rec.start_date_time;
  END IF;

  IF ((p_interaction_rec.end_date_time IS NOT NULL) AND (p_interaction_rec.end_date_time <> fnd_api.g_miss_date)) THEN
      --l_end_date_time := p_interaction_rec.end_date_time;
      l_interaction_rec.end_date_time := p_interaction_rec.end_date_time;
		END IF;

  IF l_interaction_rec.end_date_time IS NULL THEN
     --l_end_date_time := SYSDATE;
     l_interaction_rec.end_date_time := SYSDATE;
  END IF;

		Validate_StartEnd_Date
			(	p_api_name    => l_api_name_full,
				--p_start_date_time   => l_start_date_time,
				p_start_date_time   => l_interaction_rec.start_date_time,
				--p_end_date_time		=> l_end_date_time,
				p_end_date_time		=> l_interaction_rec.end_date_time,
				x_return_status     => l_return_status
			);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;

  IF((p_interaction_rec.duration <> fnd_api.g_miss_num) AND (p_interaction_rec.duration IS NOT NULL)) THEN
      --l_duration := p_interaction_rec.duration;
      l_interaction_rec.duration := p_interaction_rec.duration;
  ELSE
      -- 09/11/2002 - IAleshin
      -- If we have a value for duration then leave it, else recalculate duration for current Interaction
      --
      IF (l_interaction_rec.duration IS NULL) OR (l_interaction_rec.duration = 0) THEN
        --l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
        l_interaction_rec.duration := ROUND((l_interaction_rec.end_date_time - l_interaction_rec.start_date_time)*24*60*60);
      END IF;
  END IF;

		FOR v_activity_id_c IN l_activity_id_c LOOP

      -- Added by IAleshin 21-MAY-2002
      --
      SELECT outcome_id, action_item_id, start_date_time, end_date_time, duration
      INTO la_outcome_id, l_action_item_id, la_start_date_time, la_end_date_time, la_duration
      FROM jtf_ih_activities
      WHERE activity_id = v_activity_id_c.activity_id;


			IF (la_outcome_id IS NULL) OR (la_outcome_id = fnd_api.g_miss_num) THEN
				x_return_status := fnd_api.g_ret_sts_error;
           -- Bug# 3779487 added by nchouras 4-AUG-2004
      la_out_act_list(1).token_name := 'API_NAME';
      la_out_act_list(1).token_value := l_api_name_full;
      la_out_act_list(2).token_name := 'VALUE1';
      la_out_act_list(2).token_value := la_outcome_id;
      la_out_act_list(3).token_name := 'PARAMETER1';
      la_out_act_list(3).token_value := 'outcome_id';
      la_out_act_list(4).token_name := 'PARAMETER2';
      la_out_act_list(4).token_value := 'activity';
      la_out_act_list(5).token_name := 'PARAMETER3';
      la_out_act_list(5).token_value := 'activity_id';
      la_out_act_list(6).token_name := 'VALUE2';
      la_out_act_list(6).token_value := v_activity_id_c.activity_id;
      msg_code := 'JTF_API_ALL_INVALID_OUTCOME';
      --end Bug# 3779487

      -- Bug# 3779487 changed l_outcome_id to la_outcome_id
      --			     jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(la_outcome_id),
      --						'outcome_id');
    	-- Bug# 3779487 added by nchouras 4-AUG-2004
      jtf_ih_core_util_pvt.add_invalid_argument_msg_gen( msg_code,
                                                         la_out_act_list);

			     fnd_msg_pub.count_and_get
				  (   p_count       => x_msg_count,
				      p_data  => x_msg_data );
			     RETURN;
			END IF;

			IF (l_action_item_id IS NULL) OR (l_action_item_id = fnd_api.g_miss_num) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			     jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_action_item_id),
						'action_item_id');
			     RETURN;
			END IF;

      IF la_end_date_time IS NULL THEN
    la_end_date_time := SYSDATE;
      END IF;
		    Validate_StartEnd_Date
			     (	p_api_name    => l_api_name_full,
				    p_start_date_time   => la_start_date_time,
				    p_end_date_time		=> la_end_date_time,
				    x_return_status     => l_return_status
			     );
		      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			     RAISE fnd_api.g_exc_error;
		      END IF;

        -- 09/11/2002 - IAleshin
        -- If we have a value for duration then leave it, else recalculate duration for current Activity.
        --
        IF (la_duration IS NULL) OR (la_duration = 0) THEN
        la_duration := ROUND((la_end_date_time - la_start_date_time)*24*60*60);
        END IF;
        -- Perf fix for literal Usage
        UPDATE jtf_ih_activities SET ACTIVE = l_active_perf,
               END_DATE_TIME = la_end_date_time, DURATION = la_duration
	WHERE ACTIVITY_ID = v_activity_id_c.activity_id;

   /* --Commented by IAleshin 21-MAY-2002
      ----
			l_outcome_id := NULL;
   			SELECT outcome_id
   			into l_outcome_id
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF (l_outcome_id IS NULL) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			   jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_outcome_id),
						'outcome_id');
      -- # 1937894
      --
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				  p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
			RETURN;
			END IF;

			IF (l_action_item_id IS NULL) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			   jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_action_item_id),
						'action_item_id');
    -- # 2281489
			     fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				  p_data  => x_msg_data );
    x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
			RETURN;
			END IF;

			SELECT end_date_time, outcome_id
			into l_end_date_time, l_outcome_id
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF (l_outcome_id IS NULL) or (l_outcome_id = fnd_api.g_miss_num) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			       	jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_interaction_rec.outcome_id),
				    'outcome_id');
    -- Bug# 1937894
    --
				fnd_msg_pub.count_and_get
					( p_count       => x_msg_count,
					  p_data  => x_msg_data );
    x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
				RETURN;
			END IF;

 			IF(l_end_date_time IS NULL) or (l_end_date_time = fnd_api.g_miss_date) THEN
				l_end_date_time := SYSDATE;
			END IF;
			UPDATE jtf_ih_activities SET ACTIVE = 'N',end_date_time = l_end_date_time
					WHERE activity_id = v_activity_id_c.activity_id;*/
		END LOOP;
		-- DBMS_OUTPUT.PUT_LINE('PAST Update ACTIVE in JTF_IH_PUB.Close_Interaction');

       -- Changed location by IAleshin
       -- Bug# 2418028
	   -- Set active to 'N' for jtf_ih_interactions and related jtf_ih_activities
	   --
	   -- Check if end_date_time is currently 'null' or 'fnd_api.g_miss_date'
	   -- If either of the above is true, then set end_date_time to sysdate
	   --

           -- Perf fix for literal Usage
	   UPDATE jtf_ih_interactions
           SET ACTIVE = l_active_perf,
           START_DATE_TIME = l_interaction_rec.start_date_time,
           end_date_time = l_interaction_rec.end_date_time,
           duration = l_interaction_rec.duration
	   WHERE interaction_id = p_interaction_rec.interaction_id;

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_INTERACTION', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.close_interaction_post(p_interaction_rec=>l_interaction_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_INTERACTION', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.close_interaction_post(p_interaction_rec=>l_interaction_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;
		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO close_interaction_pub1;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				  p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO close_interaction_pub1;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO close_interaction_pub1;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');

	END Close_Interaction;

--
--
-- History
-- -------
--		Author			Date		Description
--		------			----		-----------
--		Jean Zhu 		01/11/2000	Initial Version
-- 		James Baldo Jr. 03/06/2000 	to fix bug: write cust_account_id column
-- 		James Baldo Jr. 04/20/2000 	to fix bugdb 1275539: write doc_source_object_name
--		James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--		Igor Aleshin	18-DEC-2001	Fix bug# 2153913
--      Igor Aleshin    21-DEC-2001 Fix for bugdb - 2153913 - PREVENT G_MISS_DATE VALUE FROM BEING
--            WRITTEN TO THE END_DATE_TIME VALUE.
--      Igor Aleshin    04-MAR-2002 Added Attributes to Activitiy_Rec
--      Igor Aleshin    10-MAY-2002 ENH# 2079963 - NEED INTERACTION HISTORY
--          RECORD TO SUPPORT MULTIPLE AGENTS
--      Igor Aleshin    20-MAY-2002 Changed the logic in Duration piece of code.
--      Igor Aleshin    05-JUN-2002 Removed from statemements Resource_ID for Activity_Rec_Type
--      Igor Aleshin    24-FEB-2003 Fixed bug# 2817083 - Error loggin interactions
--

PROCEDURE Add_Activity
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_activity_rec		IN	activity_rec_type,
	x_activity_id		OUT NOCOPY NUMBER
)
AS
		l_api_name   	CONSTANT VARCHAR2(30) := 'Add_Activity';
		l_api_version      	CONSTANT NUMBER       := 1.0;
		l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		l_return_status    	VARCHAR2(1);
		--l_activity_id 	    	NUMBER;
		--l_duration		NUMBER := NULL;
		--l_start_date_time	DATE;
  -- Bug# 2153913
		--l_end_date_time	    DATE;
		l_active		VARCHAR2(1);
		l_return_code		VARCHAR2(1);
		l_data			VARCHAR2(2000);
		l_count			NUMBER;
		l_activity_rec		ACTIVITY_REC_TYPE;
  -- Bug# 2817083
                l_inter_active	VARCHAR2(1) ;   -- Bug# 4477761
  DuplicateID     exception;
	BEGIN
                -- local variables initialization to remove GSCC warning
                -- l_active := 'Y';

		-- Standard start of API savepoint
		SAVEPOINT add_activity_pub;
			-- Preprocessing Call
			l_activity_rec := p_activity_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'ADD_ACTIVITY', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.add_activity_pre(p_activity_rec=>l_activity_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'ADD_ACTIVITY', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.add_activity_pre(p_activity_rec=>l_activity_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Add_Activity');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Add_Activity');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Activity_Record
		(	p_api_name      => l_api_name_full,
			p_act_val_rec   => p_activity_rec,
			p_resp_appl_id  => p_resp_appl_id,
			p_resp_id       => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST Validate_Activity_Record in JTF_IH_PUB.Add_Activity');

                -- Bug# 4477761
                -- Setting the Active status of the activity rec
                -- based on the fact whether the Interaction it is
                -- associated with is closed or open
                -- If Activity added to closed interaction active status = 'N'

   		SELECT active
 		INTO   l_inter_active
 		FROM   JTF_IH_INTERACTIONS
 		WHERE   interaction_id = p_activity_rec.interaction_id;

 		IF l_inter_active = 'Y' THEN
 		  l_active   := 'Y';
 		ELSE
 		  l_active   := 'N';
                END IF;

                --End Bug# 4477761

  -- Changed by IAleshin 20-MAY-2002
		IF (p_activity_rec.end_date_time <> fnd_api.g_miss_DATE) AND (p_activity_rec.end_date_time IS NOT NULL) THEN
		  --l_end_date_time := p_activity_rec.end_date_time;
		  l_activity_rec.end_date_time := p_activity_rec.end_date_time;
                 ELSIF l_active = 'N' THEN      --Bug# 4477761 add activity to closed interaction
                    --l_end_date_time := SYSDATE;
                    l_activity_rec.end_date_time := SYSDATE;
                 ELSE
			--l_end_date_time := null;
			l_activity_rec.end_date_time := null;
		END IF;

		IF ((p_activity_rec.start_date_time <> fnd_api.g_miss_date) AND (p_activity_rec.start_date_time IS NOT NULL)) THEN
			--l_start_date_time := p_activity_rec.start_date_time;
			l_activity_rec.start_date_time := p_activity_rec.start_date_time;
		ELSE
			--l_start_date_time := SYSDATE;
			l_activity_rec.start_date_time := SYSDATE;
		END IF;

		Validate_StartEnd_Date(	p_api_name    => l_api_name_full,
				    --p_start_date_time   => l_start_date_time,
				    p_start_date_time   => l_activity_rec.start_date_time,
				    --p_end_date_time		=> l_end_date_time,
				    p_end_date_time	    => l_activity_rec.end_date_time,
				    x_return_status     => l_return_status);
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;

		IF ((p_activity_rec.duration IS NOT NULL) AND (p_activity_rec.duration <> fnd_api.g_miss_num))THEN
			--l_duration := p_activity_rec.duration;
			l_activity_rec.duration := p_activity_rec.duration;
		ELSIF(l_activity_rec.end_date_time IS NOT NULL) THEN
			--l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
			l_activity_rec.duration := ROUND((l_activity_rec.end_date_time - l_activity_rec.start_date_time)*24*60*60);
		END IF;

  -- Removed by IAleshin 06/04/2002
  -- Enh# 2079963
  /*IF( p_activity_rec.resource_id IS NOT NULL) AND (p_activity_rec.resource_id <> fnd_api.g_miss_num) THEN
   	  SELECT count(resource_id) into l_count
    FROM jtf_rs_resource_extns
    WHERE resource_id = p_activity_rec.resource_id;
    IF (l_count <= 0) THEN
     	  x_return_status := fnd_api.g_ret_sts_error;
     	  jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_activity_rec.resource_id),'resource_id');
	         RETURN;
	      END IF;
      l_activity_rec.resource_id := p_activity_rec.resource_id;
  ELSE
      -- If resource_id is null or g_miss_num, then get value from parent interaction
      SELECT resource_id INTO l_activity_rec.resource_id
      FROM jtf_ih_interactions WHERE interaction_id = p_activity_rec.interaction_id;
  END IF;*/

  -- Bug 2817083
  --l_activity_id := Get_Activity_ID(NULL);
  l_activity_rec.activity_id := Get_Activity_ID(NULL);
		--SELECT JTF_IH_ACTIVITIES_S1.NextVal into l_activity_id FROM dual;

    validate_source_code(l_api_name_full, l_activity_rec.source_code_id, l_activity_rec.source_code, x_return_status);
		IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;

		INSERT INTO jtf_ih_Activities
		(
			ACTIVITY_ID,
			OBJECT_ID,
			OBJECT_TYPE,
			SOURCE_CODE_ID,
			SOURCE_CODE,
			DURATION,
			DESCRIPTION,
			DOC_ID,
			DOC_REF,
			DOC_SOURCE_OBJECT_NAME,
			END_DATE_TIME,
			RESULT_ID,
			REASON_ID,
			START_DATE_TIME,
			ACTION_ID,
			INTERACTION_ACTION_TYPE,
			MEDIA_ID,
			OUTCOME_ID,
			ACTION_ITEM_ID,
			INTERACTION_ID,
			TASK_ID,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN,
			CUST_ACCOUNT_ID,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
			ACTIVE,
      SCRIPT_TRANS_ID,
      ROLE
--      ,RESOURCE_ID
		)
		VALUES
		(
			--l_activity_id,
			l_activity_rec.activity_id,
			decode( p_activity_rec.object_id, fnd_api.g_miss_num, null, p_activity_rec.object_id),
      decode( p_activity_rec.object_type, fnd_api.g_miss_char, null, p_activity_rec.object_type),
			decode( l_activity_rec.source_code_id, fnd_api.g_miss_num, null, l_activity_rec.source_code_id),
			decode( l_activity_rec.source_code, fnd_api.g_miss_char, null, l_activity_rec.source_code),
			--l_duration,
			l_activity_rec.duration,
			decode( p_activity_rec.description, fnd_api.g_miss_char, null, p_activity_rec.description),
			decode( p_activity_rec.doc_id, fnd_api.g_miss_num, null, p_activity_rec.doc_id),
			decode( p_activity_rec.doc_ref, fnd_api.g_miss_char, null, p_activity_rec.doc_ref),
			decode( p_activity_rec.doc_source_object_name, fnd_api.g_miss_char, null, p_activity_rec.doc_source_object_name),
			--l_end_date_time,
			l_activity_rec.end_date_time,
			decode( p_activity_rec.result_id, fnd_api.g_miss_num, null, p_activity_rec.result_id),
			decode( p_activity_rec.reason_id, fnd_api.g_miss_num, null, p_activity_rec.reason_id),
			--l_start_date_time,
			l_activity_rec.start_date_time,
			decode( p_activity_rec.action_id, fnd_api.g_miss_num, null, p_activity_rec.action_id),
			decode( p_activity_rec.interaction_action_type, fnd_api.g_miss_char, null, p_activity_rec.interaction_action_type),
			decode( p_activity_rec.media_id, fnd_api.g_miss_num, null, p_activity_rec.media_id),
			decode( p_activity_rec.outcome_id, fnd_api.g_miss_num, null, p_activity_rec.outcome_id),
			decode( p_activity_rec.action_item_id, fnd_api.g_miss_num, null, p_activity_rec.action_item_id),
			p_activity_rec.interaction_id,
			decode( p_activity_rec.task_id, fnd_api.g_miss_num, null, p_activity_rec.task_id),
			Sysdate,
			p_user_id,
			p_user_id,
			Sysdate,
			p_login_id,
			decode( p_activity_rec.cust_account_id, fnd_api.g_miss_num, null, p_activity_rec.cust_account_id),
			decode( p_activity_rec.attribute1, fnd_api.g_miss_char, null, p_activity_rec.attribute1),
			decode( p_activity_rec.attribute2, fnd_api.g_miss_char, null, p_activity_rec.attribute2),
			decode( p_activity_rec.attribute3, fnd_api.g_miss_char, null, p_activity_rec.attribute3),
			decode( p_activity_rec.attribute4, fnd_api.g_miss_char, null, p_activity_rec.attribute4),
			decode( p_activity_rec.attribute5, fnd_api.g_miss_char, null, p_activity_rec.attribute5),
			decode( p_activity_rec.attribute6, fnd_api.g_miss_char, null, p_activity_rec.attribute6),
			decode( p_activity_rec.attribute7, fnd_api.g_miss_char, null, p_activity_rec.attribute7),
      decode( p_activity_rec.attribute8, fnd_api.g_miss_char, null, p_activity_rec.attribute8),
      decode( p_activity_rec.attribute9, fnd_api.g_miss_char, null, p_activity_rec.attribute9),
      decode( p_activity_rec.attribute10, fnd_api.g_miss_char, null, p_activity_rec.attribute10),
      decode( p_activity_rec.attribute11, fnd_api.g_miss_char, null, p_activity_rec.attribute11),
      decode( p_activity_rec.attribute12, fnd_api.g_miss_char, null, p_activity_rec.attribute12),
      decode( p_activity_rec.attribute13, fnd_api.g_miss_char, null, p_activity_rec.attribute13),
      decode( p_activity_rec.attribute14, fnd_api.g_miss_char, null, p_activity_rec.attribute14),
      decode( p_activity_rec.attribute15, fnd_api.g_miss_char, null, p_activity_rec.attribute15),
      decode( p_activity_rec.attribute_category, fnd_api.g_miss_char, null, p_activity_rec.attribute_category),
			l_active,
      decode( p_activity_rec.script_trans_id, fnd_api.g_miss_num, null, p_activity_rec.script_trans_id),
      decode( p_activity_rec.role, fnd_api.g_miss_char, null, p_activity_rec.role)
--      ,l_activity_rec.resource_id
		);
		-- DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_activities in JTF_IH_PUB.Add_Activity');

		--
		-- Set OUT value
		--
		--x_activity_id := l_activity_id;
		x_activity_id := l_activity_rec.activity_id;

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'ADD_ACTIVITY', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.add_activity_post(p_activity_rec=>l_activity_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'ADD_ACTIVITY', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.add_activity_post(p_activity_rec=>l_activity_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;




		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get(p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO add_activity_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO add_activity_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO add_activity_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Add_Activity;


--
--
-- History
-- -------
--		Author			Date		Description
--		------			----		-----------
--		Jean Zhu 		01/11/2000	Initial Version
-- 		James Baldo Jr. 03/06/2000 	to fix bug: write cust_account_id column
-- 		James Baldo Jr. 04/20/2000 	to fix bugdb 1275539: write doc_source_object_name
--		James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--		James Baldo Jr.	05-MAY-2000	Fix for updateing start_date_time bug
--      Igor Aleshin    28-SEP-2001 Fix performance issue for multiple updates. Based on bugdb # 2029051
--      Igor Aleshin    18-DEC-2001 Fix bug# 2153913
--      Igor Aleshin    04-MAR-2002 Added Attributes to Activity_Rec
--      Igor Aleshin    10-MAY-2002 ENH# 2079963 - NEED INTERACTION HISTORY RECORD TO
--          SUPPORT MULTIPLE AGENTS
--      Igor Aleshin    21-MAY-2002 Modified duration calculation
--      Igor Aleshin    05-JUN-2002 Removed from statemements Resource_ID for Activity_Rec_Type
--      Igor Aleshin    11-SEP-2002 Fixed duration overwrite issue
--      Igor Aleshin    19-FEB-2003 Fixed bug# 2804696 - TRANSACTION_ID IS NOT GETTING LOGGED IN INTERACTION TABLES
--      Igor Aleshin    29-AUG-2003 Fixed bug#3117798 - BR1159: UPDATING SOURCE CODE IN INTERACTIONS GIVES API ERROR.
--

PROCEDURE Update_Activity
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_activity_rec		IN	activity_rec_type,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL
)
AS
		l_api_name   	CONSTANT VARCHAR2(30) := 'Update_Activity';
		l_api_version      	CONSTANT NUMBER       := 1.0;
		l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		l_return_status    	VARCHAR2(1);
		--l_start_date_time	DATE;
		--l_end_date_time		DATE;
		--l_duration		NUMBER := NULL;
		l_count			NUMBER := 0;
		l_active		VARCHAR2(1) := NULL;
		l_return_code		VARCHAR2(1);
		l_data			VARCHAR2(2000);
		l_count_hk		NUMBER;
		l_activity_rec		ACTIVITY_REC_TYPE;
  -- Added by Igor
  -- 2012459
  --
  l_activity_id      NUMBER;
	    --l_cust_account_id        NUMBER;
	    --l_cust_org_id      NUMBER;
	    --l_role       VARCHAR2(240);
	    --l_task_id          NUMBER;
	    --l_doc_id           NUMBER;
	    --l_doc_ref          VARCHAR2(30);
	    --l_doc_source_object_name       VARCHAR2(80);
	    --l_media_id         NUMBER;
	    --l_action_item_id         NUMBER;
	    --l_interaction_id         NUMBER;
	    --l_outcome_id       NUMBER;
	    --l_result_id        NUMBER;
	    --l_reason_id        NUMBER;
	    --l_description      VARCHAR2(1000);
	    --l_action_id        NUMBER;
	    --l_interaction_action_type      VARCHAR2(240);
	    --l_object_id        NUMBER;
	    --l_object_type      VARCHAR2(30);
	    --l_source_code_id         NUMBER;
	    --l_source_code      VARCHAR2(100);
	    --l_script_trans_id        NUMBER;
  l_object_version         NUMBER;
  --l_attribute1       VARCHAR2(150);
  --l_attribute2       VARCHAR2(150);
  --l_attribute3       VARCHAR2(150);
  --l_attribute4       VARCHAR2(150);
  --l_attribute5       VARCHAR2(150);
  --l_attribute6       VARCHAR2(150);
  --l_attribute7       VARCHAR2(150);
  --l_attribute8       VARCHAR2(150);
  --l_attribute9       VARCHAR2(150);
  --l_attribute10       VARCHAR2(150);
  --l_attribute11       VARCHAR2(150);
  --l_attribute12       VARCHAR2(150);
  --l_attribute13       VARCHAR2(150);
  --l_attribute14       VARCHAR2(150);
  --l_attribute15       VARCHAR2(150);
  --l_attribute_category      VARCHAR2(150);
  -- Removed by IAleshin 06/05/2002
  --l_resource_id       NUMBER;
	l_recalc_duration		BOOLEAN;

  l_profile_id       VARCHAR2(20);  --profile option id check to update closed interaction

  CURSOR c_Activity_crs IS SELECT * FROM JTF_IH_ACTIVITIES
      WHERE Activity_ID = p_activity_rec.activity_id;
  rc_Activity  c_Activity_crs%ROWTYPE;

	BEGIN
		-- Stand!rd start of API savepoint
		SAVEPOINT update_activity_pub;

			-- Preprocessing Call
			l_activity_rec := p_activity_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_ACTIVITY', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.update_activity_pre(p_activity_rec=>l_activity_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_ACTIVITY', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.update_activity_pre(p_activity_rec=>l_activity_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Update_Activity');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			(	p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Update_Activity');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Activity_Record
		(	p_api_name      => l_api_name_full,
			p_act_val_rec   => p_activity_rec,
			p_resp_appl_id  => p_resp_appl_id,
			p_resp_id       => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST Validate_Activity_Record in JTF_IH_PUB.Update_Activity');

		--
		-- Update table JTF_IH_INTERACTIONS
		--
		IF (p_activity_rec.activity_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'activity_id');
				RAISE fnd_api.g_exc_error;
		ELSE
   			l_count := 0;
   			SELECT count(*) into l_count
			FROM jtf_ih_activities
			WHERE activity_id = p_activity_rec.activity_id;
			IF (l_count <> 1) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_activity_rec.activity_id),
					    'activity_id');
				RETURN;
			ELSE

    OPEN c_Activity_crs;
		      FETCH c_Activity_crs INTO  rc_Activity;
		          IF (c_Activity_crs%notfound) THEN
			         x_return_status := fnd_api.g_ret_sts_error;
			         jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, to_char(p_activity_rec.activity_id),
							   'Activity_id');
			         RETURN;
		          END IF;
      l_active := rc_Activity.Active;

                             -- Bug# 4477761 check if profile option is turned on
	    		     -- If yes then allow update on closed activity
			     fnd_profile.get('JTF_IH_ALLOW_INT_UPDATE_AFTER_CLOSE',l_profile_id);
 				IF(l_active <> 'N') OR (l_active = 'N' AND l_profile_id = 'Y') THEN
					l_recalc_duration := FALSE;
					IF (p_activity_rec.start_date_time <> fnd_api.g_miss_date) AND (p_activity_rec.start_date_time IS NOT NULL) THEN
						--l_start_date_time := p_activity_rec.start_date_time;
						l_activity_rec.start_date_time := p_activity_rec.start_date_time;
						-- duration may need to be recalculated based on the new value - RDD
						l_recalc_duration := TRUE;
					ELSE
      						--l_start_date_time := rc_Activity.Start_Date_Time;
      						l_activity_rec.start_date_time := rc_Activity.Start_Date_Time;
					END IF;

					IF ((p_activity_rec.end_date_time IS NOT NULL) AND (p_activity_rec.end_date_time <> fnd_api.g_miss_date)) THEN
						--l_end_date_time := p_activity_rec.end_date_time;
						l_activity_rec.end_date_time := rc_Activity.End_Date_Time;
						-- duration may need to be recalculated based on the new value - RDD
						l_recalc_duration := TRUE;
        ELSE
      --l_end_date_time := rc_Activity.End_Date_Time;
      l_activity_rec.end_date_time := rc_Activity.End_Date_Time;
					END IF;

					Validate_StartEnd_Date
						(	p_api_name    	=> l_api_name_full,
							--p_start_date_time   	=> l_start_date_time,
							p_start_date_time   	=> l_activity_rec.start_date_time,
							--p_end_date_time		=> l_end_date_time,
							p_end_date_time		=> l_activity_rec.end_date_time,
							x_return_status     	=> l_return_status
						);
						IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
							RAISE fnd_api.g_exc_error;
						END IF;

 			-- Determine if duration recalc can be done.  We require start and end date. - RDD
			IF l_recalc_duration = TRUE THEN
				IF l_activity_rec.end_date_time IS NULL THEN
					l_recalc_duration := FALSE;
				END IF;
			END IF;

		   -- Added expression based on the bug# 2560551
			IF(p_activity_rec.duration <> fnd_api.g_miss_num) AND (p_activity_rec.duration IS NOT NULL) THEN
				--l_duration := p_activity_rec.duration;
				l_activity_rec.duration := p_activity_rec.duration;
			ELSE
				IF l_recalc_duration = TRUE THEN
					--l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
					l_activity_rec.duration := ROUND((l_activity_rec.end_date_time - l_activity_rec.start_date_time)*24*60*60);
				ELSE
					--l_duration := rc_Activity.duration;
					l_activity_rec.duration := rc_Activity.duration;
				END IF;
			END IF;

					--IF(p_activity_rec.cust_account_id = fnd_api.g_miss_num) OR (p_activity_rec.cust_account_id IS NULL) THEN
					IF(p_activity_rec.cust_account_id = fnd_api.g_miss_num) THEN
                        --l_cust_account_id := rc_Activity.cust_account_id;
                        l_activity_rec.cust_account_id := rc_Activity.cust_account_id;
                    ELSE
                        --l_cust_account_id := p_activity_rec.cust_account_id;
                        l_activity_rec.cust_account_id := p_activity_rec.cust_account_id;
					END IF;

					--IF(p_activity_rec.cust_org_id = fnd_api.g_miss_num) OR (p_activity_rec.cust_org_id IS NULL) THEN
					IF(p_activity_rec.cust_org_id = fnd_api.g_miss_num) THEN
                        --l_cust_org_id := rc_Activity.cust_org_id;
                        l_activity_rec.cust_org_id := rc_Activity.cust_org_id;
                    ELSE
                        --l_cust_org_id := p_activity_rec.cust_org_id;
                        l_activity_rec.cust_org_id := p_activity_rec.cust_org_id;
					END IF;

					--IF(p_activity_rec.role = fnd_api.g_miss_char) OR (p_activity_rec.role IS NULL) THEN
					IF(p_activity_rec.role = fnd_api.g_miss_char)  THEN
                        --l_role := rc_Activity.role;
                        l_activity_rec.role := rc_Activity.role;
                    ELSE
                        --l_role := p_activity_rec.role;
                        l_activity_rec.role := p_activity_rec.role;
					END IF;

					--IF(p_activity_rec.outcome_id = fnd_api.g_miss_num) OR (p_activity_rec.outcome_id IS NULL) THEN
					IF(p_activity_rec.outcome_id = fnd_api.g_miss_num) THEN
                        --l_outcome_id := rc_Activity.outcome_id;
                        l_activity_rec.outcome_id := rc_Activity.outcome_id;
                    ELSE
                        --l_outcome_id := p_activity_rec.outcome_id;
                        l_activity_rec.outcome_id := p_activity_rec.outcome_id;
					END IF;

					--IF(p_activity_rec.result_id	= fnd_api.g_miss_num) OR (p_activity_rec.result_id IS NULL) THEN
					IF(p_activity_rec.result_id	= fnd_api.g_miss_num) THEN
                        --l_result_id := rc_Activity.result_id;
                        l_activity_rec.result_id := rc_Activity.result_id;
                    ELSE
                        --l_result_id := p_activity_rec.result_id;
                        l_activity_rec.result_id := p_activity_rec.result_id;
					END IF;

					--IF(p_activity_rec.reason_id	= fnd_api.g_miss_num) OR (p_activity_rec.reason_id IS NULL) THEN
					IF(p_activity_rec.reason_id	= fnd_api.g_miss_num) THEN
                        --l_reason_id := rc_Activity.reason_id;
                        l_activity_rec.reason_id := rc_Activity.reason_id;
                    ELSE
                        --l_reason_id := p_activity_rec.reason_id;
                        l_activity_rec.reason_id := p_activity_rec.reason_id;
					END IF;

					--IF(p_activity_rec.task_id = fnd_api.g_miss_num) OR (p_activity_rec.task_id IS NULL) THEN
					IF(p_activity_rec.task_id = fnd_api.g_miss_num) THEN
                        --l_task_id := rc_Activity.task_id;
                        l_activity_rec.task_id := rc_Activity.task_id;
                    ELSE
                        --l_task_id := p_activity_rec.task_id;
                        l_activity_rec.task_id := p_activity_rec.task_id;
					END IF;

					--IF(p_activity_rec.object_id	= fnd_api.g_miss_num) OR (p_activity_rec.object_id IS NULL) THEN
					IF(p_activity_rec.object_id	= fnd_api.g_miss_num) THEN
                        --l_object_id := rc_Activity.object_id;
                        l_activity_rec.object_id := rc_Activity.object_id;
                    ELSE
                        --l_object_id := p_activity_rec.object_id;
                        l_activity_rec.object_id := p_activity_rec.object_id;
					END IF;

					--IF(p_activity_rec.object_type = fnd_api.g_miss_char) OR (p_activity_rec.object_type IS NULL)  THEN
					IF(p_activity_rec.object_type = fnd_api.g_miss_char) THEN
                      --l_object_type := rc_Activity.object_type;
                      l_activity_rec.object_type := rc_Activity.object_type;
                    ELSE
                      --l_object_type := p_activity_rec.object_type;
                      l_activity_rec.object_type := p_activity_rec.object_type;
					END IF;

                    IF(p_activity_rec.source_code_id = fnd_api.g_miss_num)
                        AND (p_activity_rec.source_code = fnd_api.g_miss_char) THEN
                            --l_source_code_id := rc_Activity.source_code_id;
                            l_activity_rec.source_code_id := rc_Activity.source_code_id;
                            --l_source_code := rc_Activity.source_code;
                            l_activity_rec.source_code := rc_Activity.source_code;
                    ELSE
                        --l_source_code_id := p_activity_rec.source_code_id;
                        l_activity_rec.source_code_id := p_activity_rec.source_code_id;
                        --l_source_code := p_activity_rec.source_code;
                        l_activity_rec.source_code := p_activity_rec.source_code;
                    END IF;



					--IF(p_activity_rec.doc_id = fnd_api.g_miss_num) OR (p_activity_rec.doc_id IS NULL) THEN
					IF(p_activity_rec.doc_id = fnd_api.g_miss_num) THEN
                        --l_doc_id := rc_Activity.doc_id;
                        l_activity_rec.doc_id := rc_Activity.doc_id;
                    ELSE
                        --l_doc_id := p_activity_rec.doc_id;
                        l_activity_rec.doc_id := p_activity_rec.doc_id;
					END IF;

					--IF(p_activity_rec.doc_ref = fnd_api.g_miss_char) OR (p_activity_rec.doc_ref IS NULL) THEN
					IF(p_activity_rec.doc_ref = fnd_api.g_miss_char) THEN
                        --l_doc_ref := rc_Activity.doc_ref;
                        l_activity_rec.doc_ref := rc_Activity.doc_ref;
                    ELSE
                        --l_doc_ref := p_activity_rec.doc_ref;
                        l_activity_rec.doc_ref := p_activity_rec.doc_ref;
					END IF;

					--IF(p_activity_rec.doc_source_object_name = fnd_api.g_miss_char) OR (p_activity_rec.doc_source_object_name IS NULL) THEN
					IF(p_activity_rec.doc_source_object_name = fnd_api.g_miss_char) THEN
                        --l_doc_source_object_name := rc_Activity.doc_source_object_name;
                        l_activity_rec.doc_source_object_name := rc_Activity.doc_source_object_name;
                    ELSE
                        --l_doc_source_object_name := p_activity_rec.doc_source_object_name;
                        l_activity_rec.doc_source_object_name := p_activity_rec.doc_source_object_name;
					END IF;

					--IF(p_activity_rec.media_id = fnd_api.g_miss_num) OR (p_activity_rec.media_id IS NULL) THEN
					IF(p_activity_rec.media_id = fnd_api.g_miss_num) THEN
                        --l_media_id := rc_Activity.media_id;
                        l_activity_rec.media_id := rc_Activity.media_id;
                    ELSE
                        --l_media_id := p_activity_rec.media_id;
                        l_activity_rec.media_id := p_activity_rec.media_id;
					END IF;

					--IF(p_activity_rec.action_item_id = fnd_api.g_miss_num) OR (p_activity_rec.action_item_id IS NULL) THEN
					IF(p_activity_rec.action_item_id = fnd_api.g_miss_num) THEN
                        --l_action_item_id := rc_Activity.action_item_id;
                        l_activity_rec.action_item_id := rc_Activity.action_item_id;
                    ELSE
                        --l_action_item_id := p_activity_rec.action_item_id;
                        l_activity_rec.action_item_id := p_activity_rec.action_item_id;
					END IF;

					--IF(p_activity_rec.interaction_id = fnd_api.g_miss_num) OR (p_activity_rec.interaction_id IS NULL) THEN
					IF(p_activity_rec.interaction_id = fnd_api.g_miss_num) THEN
                        --l_interaction_id := rc_Activity.interaction_id;
                        l_activity_rec.interaction_id := rc_Activity.interaction_id;
                    ELSE
                        --l_interaction_id := p_activity_rec.interaction_id;
                        l_activity_rec.interaction_id := p_activity_rec.interaction_id;
					END IF;

					--IF(p_activity_rec.description = fnd_api.g_miss_char) OR (p_activity_rec.description IS NULL) THEN
					IF(p_activity_rec.description = fnd_api.g_miss_char) THEN
                        --l_description := rc_Activity.description;
                        l_activity_rec.description := rc_Activity.description;
                    ELSE
                        --l_description := p_activity_rec.description;
                        l_activity_rec.description := p_activity_rec.description;
					END IF;

					--IF(p_activity_rec.action_id	= fnd_api.g_miss_num) OR (p_activity_rec.action_id IS NULL) THEN
					IF(p_activity_rec.action_id	= fnd_api.g_miss_num) THEN
                        --l_action_id := rc_Activity.action_id;
                        l_activity_rec.action_id := rc_Activity.action_id;
                    ELSE
                        --l_action_id := p_activity_rec.action_id;
                        l_activity_rec.action_id := p_activity_rec.action_id;
					END IF;

					--IF(p_activity_rec.interaction_action_type = fnd_api.g_miss_char) OR (p_activity_rec.interaction_action_type IS NULL) THEN
					IF(p_activity_rec.interaction_action_type = fnd_api.g_miss_char) THEN
                        --l_interaction_action_type := rc_Activity.interaction_action_type;
                        l_activity_rec.interaction_action_type := rc_Activity.interaction_action_type;
                    ELSE
                        --l_interaction_action_type := p_activity_rec.interaction_action_type;
                        l_activity_rec.interaction_action_type := p_activity_rec.interaction_action_type;
					END IF;

 		      --
 		      -- Check if object_version_number requires updating
 		      --
 		      IF (p_object_version IS NULL)  then
                 l_object_version := rc_Activity.object_version_number;
 		      ELSE
 		         l_object_version := p_object_version;
 		      END IF;

        --
        -- Check Attributes requires updating
        --
					IF(p_activity_rec.attribute1 = fnd_api.g_miss_char) THEN
                        --l_attribute1 := rc_Activity.attribute1;
                        l_activity_rec.attribute1 := rc_Activity.attribute1;
                    ELSE
                        --l_attribute1 := p_activity_rec.attribute1;
                        l_activity_rec.attribute1 := p_activity_rec.attribute1;
					END IF;

					IF(p_activity_rec.attribute2 = fnd_api.g_miss_char) THEN
                        --l_attribute2 := rc_Activity.attribute1;
                        l_activity_rec.attribute2 := rc_Activity.attribute1;
                    ELSE
                        --l_attribute2 := p_activity_rec.attribute2;
                        l_activity_rec.attribute2 := p_activity_rec.attribute2;
					END IF;

					IF(p_activity_rec.attribute3 = fnd_api.g_miss_char) THEN
                        --l_attribute3 := rc_Activity.attribute3;
                        l_activity_rec.attribute3 := rc_Activity.attribute3;
                    ELSE
                        --l_attribute3 := p_activity_rec.attribute3;
                        l_activity_rec.attribute3 := p_activity_rec.attribute3;
					END IF;

					IF(p_activity_rec.attribute4 = fnd_api.g_miss_char) THEN
                        --l_attribute4 := rc_Activity.attribute4;
                        l_activity_rec.attribute4 := rc_Activity.attribute4;
                    ELSE
                        --l_attribute4 := p_activity_rec.attribute4;
                        l_activity_rec.attribute4 := p_activity_rec.attribute4;
					END IF;

					IF(p_activity_rec.attribute5 = fnd_api.g_miss_char) THEN
                        --l_attribute5 := rc_Activity.attribute5;
                        l_activity_rec.attribute5 := rc_Activity.attribute5;
                    ELSE
                        --l_attribute5 := p_activity_rec.attribute5;
                        l_activity_rec.attribute5 := p_activity_rec.attribute5;
					END IF;

					IF(p_activity_rec.attribute6 = fnd_api.g_miss_char) THEN
                        --l_attribute6 := rc_Activity.attribute6;
                        l_activity_rec.attribute6 := rc_Activity.attribute6;
                    ELSE
                        --l_attribute6 := p_activity_rec.attribute6;
                        l_activity_rec.attribute6 := p_activity_rec.attribute6;
					END IF;

					IF(p_activity_rec.attribute7 = fnd_api.g_miss_char) THEN
                        --l_attribute7 := rc_Activity.attribute7;
                        l_activity_rec.attribute7 := rc_Activity.attribute7;
                    ELSE
                        --l_attribute7 := p_activity_rec.attribute7;
                        l_activity_rec.attribute7 := p_activity_rec.attribute7;
					END IF;

					IF(p_activity_rec.attribute8 = fnd_api.g_miss_char) THEN
                        --l_attribute8 := rc_Activity.attribute8;
                        l_activity_rec.attribute8 := rc_Activity.attribute8;
                    ELSE
                        --l_attribute8 := p_activity_rec.attribute8;
                        l_activity_rec.attribute8 := p_activity_rec.attribute8;
					END IF;

					IF(p_activity_rec.attribute9 = fnd_api.g_miss_char) THEN
                        --l_attribute9 := rc_Activity.attribute9;
                        l_activity_rec.attribute9 := rc_Activity.attribute9;
                    ELSE
                        --l_attribute9 := p_activity_rec.attribute9;
                        l_activity_rec.attribute9 := p_activity_rec.attribute9;
					END IF;

					IF(p_activity_rec.attribute10 = fnd_api.g_miss_char) THEN
                        --l_attribute10 := rc_Activity.attribute10;
                        l_activity_rec.attribute10 := rc_Activity.attribute10;
                    ELSE
                        --l_attribute10 := p_activity_rec.attribute10;
                        l_activity_rec.attribute10 := p_activity_rec.attribute10;
					END IF;

					IF(p_activity_rec.attribute11 = fnd_api.g_miss_char) THEN
                        --l_attribute11 := rc_Activity.attribute11;
                        l_activity_rec.attribute11 := rc_Activity.attribute11;
                    ELSE
                        --l_attribute11 := p_activity_rec.attribute11;
                        l_activity_rec.attribute11 := p_activity_rec.attribute11;
					END IF;

					IF(p_activity_rec.attribute12 = fnd_api.g_miss_char) THEN
                        --l_attribute12 := rc_Activity.attribute12;
                        l_activity_rec.attribute12 := rc_Activity.attribute12;
                    ELSE
                        --l_attribute12 := p_activity_rec.attribute12;
                        l_activity_rec.attribute12 := p_activity_rec.attribute12;
					END IF;

					IF(p_activity_rec.attribute13 = fnd_api.g_miss_char) THEN
                        --l_attribute13 := rc_Activity.attribute13;
                        l_activity_rec.attribute13 := rc_Activity.attribute13;
                    ELSE
                        --l_attribute13 := p_activity_rec.attribute13;
                        l_activity_rec.attribute13 := p_activity_rec.attribute13;
					END IF;

					IF(p_activity_rec.attribute14 = fnd_api.g_miss_char) THEN
                        --l_attribute14 := rc_Activity.attribute14;
                        l_activity_rec.attribute14 := rc_Activity.attribute14;
                    ELSE
                        --l_attribute14 := p_activity_rec.attribute14;
                        l_activity_rec.attribute14 := p_activity_rec.attribute14;
					END IF;

					IF(p_activity_rec.attribute15 = fnd_api.g_miss_char) THEN
                        --l_attribute15 := rc_Activity.attribute15;
                        l_activity_rec.attribute15 := rc_Activity.attribute15;
                    ELSE
                        --l_attribute15 := p_activity_rec.attribute15;
                        l_activity_rec.attribute15 := p_activity_rec.attribute15;
					END IF;

					IF(p_activity_rec.attribute_category = fnd_api.g_miss_char) THEN
                        --l_attribute_category := rc_Activity.attribute_category;
                        l_activity_rec.attribute_category := rc_Activity.attribute_category;
                    ELSE
                        --l_attribute_category := p_activity_rec.attribute_category;
                        l_activity_rec.attribute_category := p_activity_rec.attribute_category;
					END IF;

        -- Bug# 2804696
					IF(p_activity_rec.script_trans_id = fnd_api.g_miss_num) THEN
                        --l_script_trans_id := rc_Activity.script_trans_id;
                        l_activity_rec.script_trans_id := rc_Activity.script_trans_id;
                    ELSE
                        --l_script_trans_id := p_activity_rec.script_trans_id;
                        l_activity_rec.script_trans_id := p_activity_rec.script_trans_id;
					END IF;


        -- Removed by IAleshin - 06/05/2002
        /*
					IF(p_activity_rec.resource_id = fnd_api.g_miss_num) THEN
      l_resource_id := rc_Activity.resource_id;
        ELSE
      SELECT count(resource_id) into l_count
          FROM jtf_rs_resource_extns
        WHERE resource_id = p_activity_rec.resource_id;
        IF (l_count <= 0) THEN
     	      x_return_status := fnd_api.g_ret_sts_error;
     	      jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_activity_rec.resource_id),'resource_id');
	           RETURN;
	          END IF;
      l_resource_id := p_activity_rec.resource_id;
					END IF;*/

        -- 08/26/03 mpetrosi B3102306
        -- added cross check of source_code, source_code_id
        validate_source_code(l_api_name, l_activity_rec.source_code_id,
                             l_activity_rec.source_code, l_return_status);
		    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			    RAISE fnd_api.g_exc_error;
		    END IF;

        UPDATE jtf_ih_activities SET
	           cust_account_id = l_activity_rec.cust_account_id,
	           cust_org_id = l_activity_rec.cust_org_id,
	           role = l_activity_rec.role,
	           LAST_UPDATED_BY	= p_user_id,
                   LAST_UPDATE_DATE	= sysdate,
	           end_date_time = l_activity_rec.end_date_time,
	           start_date_time = l_activity_rec.start_date_time,
                   duration = l_activity_rec.duration,
	           task_id = l_activity_rec.task_id,
	           doc_id = l_activity_rec.doc_id,
	           doc_ref = l_activity_rec.doc_ref,
	           doc_source_object_name = l_activity_rec.doc_source_object_name,
	           media_id = l_activity_rec.media_id,
	           action_item_id = l_activity_rec.action_item_id,
	           outcome_id = l_activity_rec.outcome_id,
	           result_id = l_activity_rec.result_id,
	           reason_id = l_activity_rec.reason_id,
	           description = l_activity_rec.description,
	           action_id = l_activity_rec.action_id,
	           interaction_action_type = l_activity_rec.interaction_action_type,
	           object_id = l_activity_rec.object_id,
	           object_type = l_activity_rec.object_type,
	           source_code_id = decode( l_activity_rec.source_code_id, fnd_api.g_miss_num, NULL, l_activity_rec.source_code_id),
	           source_code = decode( l_activity_rec.source_code, fnd_api.g_miss_char, NULL, l_activity_rec.source_code),
	           script_trans_id = l_activity_rec.script_trans_id,
               object_version_number = l_object_version,
               attribute1 = l_activity_rec.attribute1,
               attribute2 = l_activity_rec.attribute2,
               attribute3 = l_activity_rec.attribute3,
               attribute4 = l_activity_rec.attribute4,
               attribute5 = l_activity_rec.attribute5,
               attribute6 = l_activity_rec.attribute6,
               attribute7 = l_activity_rec.attribute7,
               attribute8 = l_activity_rec.attribute8,
               attribute9 = l_activity_rec.attribute9,
               attribute10 = l_activity_rec.attribute10,
               attribute11 = l_activity_rec.attribute11,
               attribute12 = l_activity_rec.attribute12,
               attribute13 = l_activity_rec.attribute13,
               attribute14 = l_activity_rec.attribute14,
               attribute15 = l_activity_rec.attribute15,
               attribute_category = l_activity_rec.attribute_category
         -- resource_id = l_resource_id
        WHERE Activity_id = p_activity_rec.activity_id;
        CLOSE c_Activity_crs;
				ELSE
				  --jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(p_activity_rec.activity_id),
  				  --    'activity is currently set to N');
				  --Bug# 4477761 new error msg
				  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
				    fnd_message.set_name('JTF', 'JTF_IH_ACT_UPDATE_NOT_ALLOW');
				    fnd_message.set_token('ACT_ID', to_char(p_activity_rec.activity_id));
				    fnd_msg_pub.add;
 	                          END IF;
				  RAISE fnd_api.g_exc_error ;
				END IF;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST update table jtf_ih_activities in JTF_IH_PUB.Update_Activity');

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_ACTIVITY', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.update_activity_post(p_activity_rec=>l_activity_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_ACTIVITY', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.update_activity_post(p_activity_rec=>l_activity_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO update_activity_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO update_activity_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO update_activity_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Update_Activity;

--
--
-- History
-- -------
--		Author			Date		Description
--		------			----		-----------
--		Jean Zhu		01/11/2000	Initial build
--		James Baldo Jr.		25-APR-2000	User Hooks Customer and Vertical Industry
--		James Baldo Jr.		24-MAY-2000	Implementation fix for bugdb 1311491 - duration not being calculated
--		James Baldo Jr.		27-JUL-2000	Implementation fix for bugdb 1339925 - start_date_time > end_date_time
--      Igor Aleshin  21-MAY-2002 Modified duration calculation for Activities
--      Igor Aleshin  11-SEP-2002 Fixed bug# 2560551 - TST1158.8: FUNC: DEBUG - ALL INTERACTIONS
--              DISPLAYS INTERACTION DURATION AS 0
--  vekrishn        27-JUL-2004 Perf Fix for literal Usage
--
--

PROCEDURE Close_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_interaction_id	IN	NUMBER
)
AS
		l_api_name   	CONSTANT VARCHAR2(30) := 'Close_Interaction';
		l_api_version      	CONSTANT NUMBER       := 1.0;
		l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		l_return_status    	VARCHAR2(1);
		l_outcome_id		NUMBER := NULL;
		l_end_date_time		DATE := NULL;
		l_start_date_time	DATE := NULL;
		l_duration		NUMBER := NULL;
		l_action_item_id	NUMBER := NULL;
		l_return_code		VARCHAR2(1);
		l_data			VARCHAR2(2000);
		l_count_hk		NUMBER;
		l_interaction_id	NUMBER;

  -- Bug# 2560551
    la_outcome_id		NUMBER := NULL;
		la_end_date_time	DATE := NULL;
		la_start_date_time	DATE := NULL;
		la_duration		    NUMBER := NULL;
  -- Bug# 3779487
  	msg_code 			VARCHAR2(50);
		la_out_act_list		jtf_ih_core_util_pvt.param_tbl_type;

  -- Perf fix for literal Usage
  l_duration_perf          NUMBER;
  l_active_perf            VARCHAR2(1);

		 CURSOR	l_activity_id_c IS
			SELECT activity_id FROM jtf_ih_activities
			WHERE interaction_id = p_interaction_id;
	BEGIN
		SAVEPOINT close_interaction_pub2;

   -- Perf variables
   l_duration_perf := 0;
   l_active_perf := 'N';

			-- Preprocessing Call
			l_interaction_id := p_interaction_id;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_INTERACTION', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.close_interaction_pre(p_interaction_id=>l_interaction_id,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_INTERACTION', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.close_interaction_pre(p_interaction_id=>l_interaction_id,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
		RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Close_Interaction_2');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Close_Interaction_2');

   	SELECT outcome_id, end_date_time, start_date_time, duration
        INTO l_outcome_id, l_end_date_time, l_start_date_time, l_duration
        FROM jtf_ih_interactions
        WHERE interaction_id = p_interaction_id;
		IF ((l_outcome_id IS NULL) OR (l_outcome_id = fnd_api.g_miss_num)) THEN
			x_return_status := fnd_api.g_ret_sts_error;
	       jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_outcome_id),
				    'outcome_id');
		RETURN;
		END IF;

--	SELECT end_date_time, start_date_time into l_end_date_time, l_start_date_time
--	FROM jtf_ih_interactions
--	WHERE interaction_id = p_interaction_id;

		IF ((l_end_date_time IS NULL) OR (l_end_date_time = FND_API.G_MISS_DATE)) THEN
			l_end_date_time := SYSDATE;
		END IF;
		Validate_StartEnd_Date
			(	p_api_name    => l_api_name_full,
				p_start_date_time   => l_start_date_time,
				p_end_date_time		=> l_end_date_time,
				x_return_status     => l_return_status
			);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;

  IF (l_duration = 0) OR (l_duration IS NULL) THEN
		  l_duration := ROUND(( l_end_date_time - l_start_date_time)*24*60*60);
  END IF;

		FOR v_activity_id_c IN l_activity_id_c LOOP
      --
      -- Added by IAleshin 21-MAY-2002
      --
      SELECT outcome_id, action_item_id, start_date_time, end_date_time, duration
      INTO la_outcome_id, l_action_item_id, la_start_date_time, la_end_date_time, la_duration
      FROM jtf_ih_activities
      WHERE activity_id = v_activity_id_c.activity_id;


			IF (l_outcome_id IS NULL) OR (l_outcome_id = fnd_api.g_miss_num) THEN
				x_return_status := fnd_api.g_ret_sts_error;

      -- Bug# 3779487 added by nchouras 4-AUG-2004
      la_out_act_list(1).token_name := 'API_NAME';
      la_out_act_list(1).token_value := l_api_name_full;
      la_out_act_list(2).token_name := 'VALUE1';
      la_out_act_list(2).token_value := la_outcome_id;
      la_out_act_list(3).token_name := 'PARAMETER1';
      la_out_act_list(3).token_value := 'outcome_id';
      la_out_act_list(4).token_name := 'PARAMETER2';
      la_out_act_list(4).token_value := 'activity';
      la_out_act_list(5).token_name := 'PARAMETER3';
      la_out_act_list(5).token_value := 'activity_id';
      la_out_act_list(6).token_name := 'VALUE2';
      la_out_act_list(6).token_value := v_activity_id_c.activity_id;
      msg_code := 'JTF_API_ALL_INVALID_OUTCOME';
      --end Bug# 3779487

			   -- jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_outcome_id),
					--	'outcome_id');
        jtf_ih_core_util_pvt.add_invalid_argument_msg_gen( msg_code,
                                                           la_out_act_list);
			     fnd_msg_pub.count_and_get
				  (   p_count       => x_msg_count,
				      p_data  => x_msg_data );
			     RETURN;
			END IF;

			IF (l_action_item_id IS NULL) OR (l_action_item_id = fnd_api.g_miss_num) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			     jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_action_item_id),
						'action_item_id');
			     RETURN;
			END IF;

      -- Bug# 2560551
      IF (la_end_date_time IS NULL) OR (la_end_date_time = fnd_api.g_miss_date) THEN
      -- IF (l_end_date_time IS NULL) THEN
    la_end_date_time := SYSDATE;
      END IF;

		    Validate_StartEnd_Date
			     (	p_api_name    => l_api_name_full,
				    p_start_date_time   => la_start_date_time,
				    p_end_date_time		=> la_end_date_time,
				    x_return_status     => l_return_status
			    );

		      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			     RAISE fnd_api.g_exc_error;
		      END IF;
        IF (la_duration = 0) OR (la_duration IS NULL) THEN
        la_duration := ROUND((la_end_date_time - la_start_date_time)*24*60*60);
        END IF;
			  UPDATE jtf_ih_activities SET ACTIVE = l_active_perf,END_DATE_TIME = la_end_date_time, DURATION = la_duration
					WHERE ACTIVITY_ID = v_activity_id_c.activity_id;
			/*l_outcome_id := NULL;
   			SELECT outcome_id into l_outcome_id
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF (l_outcome_id IS NULL) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			   jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_outcome_id),
						'outcome_id');
			RETURN;
			END IF;

			l_action_item_id := NULL;
   			SELECT action_item_id into l_action_item_id
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF (l_action_item_id IS NULL) THEN
				x_return_status := fnd_api.g_ret_sts_error;
			   jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name_full, to_char(l_action_item_id),
						'action_item_id');
			RETURN;
			END IF;

			l_duration := NULL;
			SELECT end_date_time, start_date_time into l_end_date_time, l_start_date_time
			FROM jtf_ih_activities
			WHERE activity_id = v_activity_id_c.activity_id;
			IF ((l_end_date_time IS NULL) OR (l_end_date_time = FND_API.G_MISS_DATE)) THEN
				l_end_date_time := SYSDATE;
			END IF;
			l_duration := ROUND((l_end_date_time - l_start_date_time) * 24 * 60);


					IF l_duration = FND_API.G_MISS_NUM
	           THEN l_duration:= NULL;
	        END IF;

			UPDATE jtf_ih_activities SET ACTIVE = 'N',end_date_time = l_end_date_time, duration = l_duration
					WHERE interaction_id = p_interaction_id;*/
		END LOOP;
		-- DBMS_OUTPUT.PUT_LINE('PAST Update ACTIVE in JTF_IH_PUB.Close_Interaction_2');

  -- Bug# 2418345
		--
		-- Set active to 'N' for jtf_ih_interactions and related jtf_ih_activities
		--
                -- Perf fix for literal Usage
		UPDATE jtf_ih_interactions SET ACTIVE = l_active_perf,end_date_time =l_end_date_time,
      duration = decode(l_duration, fnd_api.g_miss_num, l_duration_perf, l_duration)
				WHERE interaction_id = p_interaction_id;

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_INTERACTION', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.close_interaction_post(p_interaction_id=>l_interaction_id,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_INTERACTION', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.close_interaction_post(p_interaction_id=>l_interaction_id,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;



		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO close_interaction_pub2;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO close_interaction_pub2;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO close_interaction_pub2;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Close_Interaction;


--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	Jean Zhu	11-JAN-2000	INITIAL VERSION
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--	James Baldo Jr.	31-JUL-2000	Implementation fix for bugdb # 1341094 to correct
--					updates on activities that have ACTIVE = N
--	Igor Aleshin	5-NOV-2002	Fixed bug# 2656975 - IH-API:  UPDATE_ACTIVITITYDURATION
--					NOT CALCULATING THE DURATION CORRECTLY.
--	Rick Day	19-NOV-2002     Corrected issues with coding of 2656975 and general proc. structure
PROCEDURE Update_ActivityDuration
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_activity_id		IN	NUMBER,
	p_end_date_time		IN  DATE,
	p_duration			IN	NUMBER,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL

)
AS
	l_api_name   	CONSTANT VARCHAR2(30) := 'Update_ActivityDuration';
	l_api_version      	CONSTANT NUMBER       := 1.0;
	l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
	l_return_status    	VARCHAR2(1);
	l_start_date_time	DATE;
	l_return_code		VARCHAR2(1);
	l_data			    VARCHAR2(2000);
	l_count			    NUMBER;
	l_activity_id		NUMBER;
	l_end_date_time		DATE;
	l_duration		    NUMBER;
	l_active		    VARCHAR2(1) := NULL;
	l_recalc_duration   BOOLEAN := TRUE;
	BEGIN

		-- Standard start of API savepoint
		SAVEPOINT update_activityDuration;

		-- No Activity ID - No Update possible
		IF (p_activity_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'activity_id');
			RAISE fnd_api.g_exc_error;
		END IF;

		-- If duration and end_date are null or have g_miss values then raise an exception
		-- "Not specified required End_Date_Time and Duration"
		-- Bug# 2656975
		IF ((p_duration IS NULL) OR (p_duration = fnd_api.g_miss_num)) AND
			((p_end_date_time IS NULL) OR (p_end_date_time = fnd_api.g_miss_date )) THEN
		    FND_MESSAGE.SET_NAME('JTF','JTF_IH_NO_DURATION_END_DATE');
		    FND_MSG_PUB.Add;
		    RAISE fnd_api.g_exc_error;
		END IF;

		-- set the local variables
		l_activity_id := p_activity_id;
		l_end_date_time := p_end_date_time;
		l_duration := p_duration;


		-- Preprocessing Call
		IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_ACTIVITYDURATION', 'B', 'C') THEN
			JTF_IH_PUB_CUHK.update_actduration_pre(
							p_activity_id=>l_activity_id,
							p_end_date_time=>l_end_date_time,
							p_duration=>l_duration,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
			IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

		IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_ACTIVITYDURATION', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.update_actduration_pre(
							p_activity_id=>l_activity_id,
							p_end_date_time=>l_end_date_time,
							p_duration=>l_duration,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
			IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;


		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
		      RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Update_ActivityDuration');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
			fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			(	p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Update_ActivityDuration');

		--
		-- Get the current activity values
		--

		SELECT start_date_time, end_date_time, duration, active into
			l_start_date_time, l_end_date_time, l_duration, l_active
			FROM jtf_ih_activities
			WHERE activity_id = p_activity_id;
		--
		-- If the activity is not active, then refuse the update.
		--
		If l_active = 'N' then
			x_return_status := fnd_api.g_ret_sts_error;
      		jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, l_active,
					    'ACTIVE');
			RAISE fnd_api.g_exc_error;
		END IF;

		-- Bug# 2656975 Determine if the end_date needs updating - RDD
		IF (p_end_date_time <> fnd_api.g_miss_date ) THEN

			-- set the date from what is passed.
			l_end_date_time := p_end_date_time;

			-- validate it with the start date time if not nulling the value
			IF (p_end_date_time IS NOT NULL) THEN
				Validate_StartEnd_Date
				(	p_api_name    => l_api_name_full,
					p_start_date_time   => l_start_date_time,
					p_end_date_time		=> l_end_date_time,
					x_return_status     => l_return_status
				);
				IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
					RAISE fnd_api.g_exc_error;
				END IF;
				-- DBMS_OUTPUT.PUT_LINE('PAST Validate_StartEnd_Date in JTF_IH_PUB.Update_ActivityDuration');
			END IF;
		END IF;

		-- Bug# 2656975 Determine how the duration is to be updated - RDD
		--   If the duration is not passed, then calculate it.
		--	   else Make sure negative durations are not allowed.
		--	   else use the passed value
		IF (p_duration IS NULL) OR (p_duration = fnd_api.g_miss_num) THEN
		    l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
		ELSIF p_duration < 0 THEN
		    l_duration := 0;
		ELSE
		    l_duration := p_duration;
		END IF;

		-- Update the activity
		UPDATE jtf_ih_activities SET END_DATE_TIME = l_end_date_time,
						DURATION = l_duration,
						OBJECT_VERSION_NUMBER = p_object_version
    	WHERE activity_id = p_activity_id;
		-- DBMS_OUTPUT.PUT_LINE('PAST update end_date_time and duration in JTF_IH_PUB.Update_ActivityDuration');

		-- Post processing Call

		IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_ACTIVITYDURATION', 'A', 'V') THEN
			JTF_IH_PUB_VUHK.update_actduration_post(
							p_activity_id=>l_activity_id,
							p_end_date_time=>l_end_date_time,
							p_duration=>l_duration,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
			IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

		IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_ACTIVITYDURATION', 'A', 'C') THEN
			JTF_IH_PUB_CUHK.update_actduration_post(
							p_activity_id=>l_activity_id,
							p_end_date_time=>l_end_date_time,
							p_duration=>l_duration,
						     	x_data=>l_data,
						     	x_count=>l_count,
						     	x_return_code=>l_return_code);
			IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO update_activityDuration;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO update_activityDuration;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO update_activityDuration;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Update_ActivityDuration;


--
--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	James Baldo Jr.	15-MAR-2000	Initial Version after losing file
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--	James Baldo Jr. 30-NOV-2000	Logic for two new columns, Media_Abandon_Flag and Media_Transferred_Flag.
--					Enhancement Bugdb # 1501325
--  Igor Aleshin    18-DEC-2001 Bug# 2153913 - PREVENT G_MISS_DATE VALUE FROM BEING WRITTEN TO
--            THE END_DATE_TIME VALUE.
--  Igor Aleshin    21-MAY-2002 Removed decode function from Source_Item_Create_Date_Time in Insert
--            statement
--  Igor Aleshin    24-FEB-2003 Fixed bug# 2817083 - Error loggin interactions
--  Igor Aleshin    03-JUL-2003 Enh# 3022511 - Add a column to the jtf_ih_media_items table
--  vekrishn        27-JUL-2004 Perf Fix for literal Usage
--
--

PROCEDURE Open_MediaItem
(
   p_api_version	IN	NUMBER,
   p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
   p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
   p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
   p_resp_id	IN	NUMBER		DEFAULT NULL,
   p_user_id	IN	NUMBER,
   p_login_id	IN	NUMBER		DEFAULT NULL,
   x_return_status	OUT NOCOPY	VARCHAR2,
   x_msg_count	OUT NOCOPY	NUMBER,
   x_msg_data	OUT NOCOPY	VARCHAR2,
   p_media_rec	IN	media_rec_type,
   x_media_id	OUT NOCOPY NUMBER
) AS
   l_api_name   	CONSTANT VARCHAR2(30) := 'Open_MediaItem';
   l_api_version      	CONSTANT NUMBER       := 1.0;
   l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
   l_return_status    	VARCHAR2(1);
   --l_media_id		NUMBER;
   --l_start_date_time	DATE;
   -- Bug# 2153913
   --l_end_date_time	    DATE;
   l_active		VARCHAR2(1);
   --l_duration		NUMBER := NULL;
   l_return_code		VARCHAR2(1);
   l_data			VARCHAR2(2000);
   l_count			NUMBER;
   l_media_rec		MEDIA_REC_TYPE;
   --l_source_item_create_date_time DATE;
   --l_address       VARCHAR2(2000);

   -- Perf fix for literal Usage
   l_ao_update_pending_perf VARCHAR2(1);
   l_soft_closed_perf       VARCHAR2(1);
BEGIN
   -- local variables initialization to remove GSCC warning
   l_active := 'Y';

   -- Perf variables
   l_ao_update_pending_perf := 'N';
   l_soft_closed_perf := 'N';

   -- Standard start of API savepoint
   SAVEPOINT open_mediaitem_pub;

   -- Preprocessing Call
   l_media_rec := p_media_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'OPEN_MEDIAITEM', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.open_mediaitem_pre(p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'OPEN_MEDIAITEM', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.open_mediaitem_pre(p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Open_MediaItem');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
			fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
			  p_parameter_name_usr    => 'p_user_id',
			  p_parameter_name_log    => 'p_login_id',
			  p_user_id         => p_user_id,
			  p_login_id        => p_login_id,
			  x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Open_MediaItem');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Media_Item
		(	p_api_name      => l_api_name_full,
			p_media_item_val      => p_media_rec,
			p_resp_appl_id  => p_resp_appl_id,
			p_resp_id       => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST Validate_MediaItem_Record in JTF_IH_PUB.Open_MediaItem');

  -- Bug# 2153913
		-- Assign the end_date_time
		IF (p_media_rec.end_date_time <> fnd_api.g_miss_date) THEN
			--l_end_date_time := p_media_rec.end_date_time;
			l_media_rec.end_date_time := p_media_rec.end_date_time;
		ELSE
			--l_end_date_time := NULL;
			l_media_rec.end_date_time := NULL;
		END IF;

		-- Assign the start_date_time
		--IF ((p_media_rec.start_date_time IS NOT NULL) AND (p_media_rec.start_date_time <> fnd_api.g_miss_date)) THEN
		IF (p_media_rec.start_date_time <> fnd_api.g_miss_date) THEN
			--l_start_date_time := p_media_rec.start_date_time;
			l_media_rec.start_date_time := p_media_rec.start_date_time;
		ELSE
			--l_start_date_time := SYSDATE;
			l_media_rec.start_date_time := SYSDATE;
		END IF;

  -- Changed by IAleshin 21-MAY-2002
	    Validate_StartEnd_Date
			(	p_api_name    => l_api_name_full,
				--p_start_date_time => l_start_date_time,
				p_start_date_time   => l_media_rec.start_date_time,
				--p_end_date_time   => l_end_date_time,
				p_end_date_time	    => l_media_rec.end_date_time,
				x_return_status     => l_return_status
			);
  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
  END IF;

		IF (p_media_rec.duration <> fnd_api.g_miss_num) AND (p_media_rec.duration IS NOT NULL) THEN
			--l_duration := p_media_rec.duration;
			l_media_rec.duration := p_media_rec.duration;
		ELSE
			--l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
			l_media_rec.duration := ROUND((l_media_rec.end_date_time - l_media_rec.start_date_time)*24*60*60);
		END IF;

  IF(p_media_rec.source_item_create_date_time <> fnd_api.g_miss_date) AND (p_media_rec.source_item_create_date_time IS NOT NULL) THEN
      --l_source_item_create_date_time := p_media_rec.source_item_create_date_time;
      l_media_rec.source_item_create_date_time := p_media_rec.source_item_create_date_time;
  ELSE
      --l_source_item_create_date_time := NULL;
      l_media_rec.source_item_create_date_time := NULL;
  END IF;

  IF (p_media_rec.address = fnd_api.g_miss_char) THEN
      IF p_media_rec.direction = 'INBOUND'
    AND p_media_rec.media_item_type LIKE 'TELE%'
    AND p_media_rec.ani <> fnd_api.g_miss_char THEN
        --l_address := p_media_rec.ani;
        l_media_rec.address := p_media_rec.ani;
      END IF;
  ELSE
      --l_address := p_media_rec.address;
      l_media_rec.address := p_media_rec.address;
  END IF;

  -- Bug# 2817083
		--SELECT JTF_IH_MEDIA_ITEMS_S1.NextVal into l_media_id FROM dual;
  --l_media_id := Get_Media_Id(NULL);
  l_media_rec.media_id := Get_Media_Id(NULL);

		INSERT INTO jtf_ih_media_items
		(
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 MEDIA_ID,
			 DURATION,
			 DIRECTION,
			 END_DATE_TIME,
			 SOURCE_ITEM_CREATE_DATE_TIME,
			 SOURCE_ITEM_ID,
			 START_DATE_TIME,
			 SOURCE_ID,
			 MEDIA_ITEM_TYPE,
			 MEDIA_ITEM_REF,
			 MEDIA_DATA,
			 MEDIA_ABANDON_FLAG,
			 MEDIA_TRANSFERRED_FLAG,
			 ACTIVE,
             SERVER_GROUP_ID,
             DNIS,
             ANI,
             CLASSIFICATION,
             ADDRESS,
             AO_UPDATE_PENDING,
             SOFT_CLOSED
			)
			VALUES
			(
			 p_user_id,
			 Sysdate,
			 p_user_id,
			 Sysdate,
			 p_login_id,
			 --l_media_id,
			 l_media_rec.media_id,
			 --l_duration,
			 l_media_rec.duration,
			 decode( p_media_rec.direction, fnd_api.g_miss_char, null, p_media_rec.direction),
			 --l_end_date_time,
			 l_media_rec.end_date_time,
       -- Added by IAleshin 21-MAY-2002
			 --l_source_item_create_date_time,
			 l_media_rec.source_item_create_date_time,
			 decode( p_media_rec.source_item_id, fnd_api.g_miss_num, null, p_media_rec.source_item_id),
			 --l_start_date_time,
			 l_media_rec.start_date_time,
			 decode( p_media_rec.source_id, fnd_api.g_miss_num, null, p_media_rec.source_id),
			 decode( p_media_rec.media_item_type, fnd_api.g_miss_char, null, p_media_rec.media_item_type),
			 decode( p_media_rec.media_item_ref, fnd_api.g_miss_char, null, p_media_rec.media_item_ref),
			 decode( p_media_rec.media_data, fnd_api.g_miss_char, null, p_media_rec.media_data),
			 decode( p_media_rec.media_abandon_flag, fnd_api.g_miss_char, null, p_media_rec.media_abandon_flag),
			 decode( p_media_rec.media_transferred_flag, fnd_api.g_miss_char, null, p_media_rec.media_transferred_flag),
			 l_active,
             decode( p_media_rec.server_group_id, fnd_api.g_miss_num, null, p_media_rec.server_group_id),
             decode( p_media_rec.dnis, fnd_api.g_miss_char, null, p_media_rec.dnis),
             decode( p_media_rec.ani, fnd_api.g_miss_char, null, p_media_rec.ani),
             decode( p_media_rec.classification, fnd_api.g_miss_char, null, p_media_rec.classification),
             --decode( l_address, fnd_api.g_miss_char, null, l_address),
             decode( l_media_rec.address, fnd_api.g_miss_char, null, l_media_rec.address),
             l_ao_update_pending_perf,
             l_soft_closed_perf
			);
		-- DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO jtf_ih_media_items in JTF_IH_PUB.Open_MediaItem');


		--
		-- Set OUT value
		--
		--x_media_id := l_media_id;
		x_media_id := l_media_rec.media_id;

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'OPEN_MEDIAITEM', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.open_mediaitem_post(p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'OPEN_MEDIAITEM', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.open_mediaitem_post(p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO open_mediaitem_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO open_mediaitem_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO open_mediaitem_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Open_MediaItem;


--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	James Baldo Jr.	15-MAR-2000	Initial Version after losing file
--	James Baldo Jr.	21-APR-2000	Active setting defect based on bugdb# 127726
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--	James Baldo Jr. 30-NOV-2000	Logic for two new columns, Media_Abandon_Flag and Media_Transferred_Flag.
--					Enhancement Bugdb # 1501325
--  Igor Aleshin    18-DEC-2001 Bug# 2153913 - PREVENT G_MISS_DATE VALUE FROM BEING WRITTEN TO
--            THE END_DATE_TIME VALUE.
--  Igor Aleshin    07-MAY-2002 Bug# 2338832 - 1156-1157: IH API G_MISS CLEAN-UP REPLACEMENT PATCH
--  Igor Aleshin    09-MAY-2002 Bug# 2363404 - IH API: ITEM NOT ALLOWING NULLS
--  Igor Aleshin    20-MAY-2002 Modified duration Calculation
--  Igor Aleshin    29-MAY-2003 Enh# 2940473 - IH Bulk API Changes
--  Igor Aleshin    03-JUL-2003 Enh# 3022511 - Add a column to the jtf_ih_media_items table
--  Igor Aleshin	15-MAR-2004 Enh# 3491849 - JTH.R: IH CHANGES TO SUPPORT FTC ABANDONMENT REGULATIONS
--

	PROCEDURE Update_MediaItem
	(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_media_rec	IN	media_rec_type,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL
	) AS
	l_api_name   			CONSTANT VARCHAR2(30) := 'Update_MediaItem';
	l_api_version      			CONSTANT NUMBER       := 1.0;
	l_api_name_full    			CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
	l_return_status    			VARCHAR2(1);
	l_media_id				NUMBER;
    -- Commented by IAleshin 20-MAY-2002
/*	l_source_id				NUMBER :=fnd_api.g_miss_num;
	l_direction				VARCHAR2(240) :=fnd_api.g_miss_char;
	l_duration				NUMBER :=fnd_api.g_miss_num;
	l_end_date_time				DATE :=fnd_api.g_miss_date;
	l_interaction_performed			VARCHAR2(240) :=fnd_api.g_miss_char;
	l_start_date_time			DATE :=fnd_api.g_miss_date;
	l_media_data				VARCHAR2(80) :=fnd_api.g_miss_char;
	l_source_item_create_date_time		DATE :=fnd_api.g_miss_date;
	l_source_item_id			NUMBER :=fnd_api.g_miss_num;
	l_media_item_type			VARCHAR2(80) :=fnd_api.g_miss_char;
	l_media_item_ref			VARCHAR2(240) :=fnd_api.g_miss_char;
	l_media_abandon_flag			VARCHAR2(1) :=fnd_api.g_miss_char;
	l_media_transferred_flag		VARCHAR2(1) :=fnd_api.g_miss_char;*/
	l_media_rec                             media_rec_type;
	l_return_code				VARCHAR2(1);
	l_data					VARCHAR2(2000);
	l_count					NUMBER;
	--l_media_rec_hk				MEDIA_REC_TYPE;
    l_object_version  NUMBER;
    l_address         VARCHAR2(2000);
    b_Duration			BOOLEAN := FALSE;

	CURSOR c_MediaItem_csr IS
		SELECT *
		FROM 	JTF_IH_MEDIA_ITEMS
		WHERE 	media_id = p_media_rec.media_id
		FOR UPDATE;
	l_MediaItem_rec	c_MediaItem_csr%ROWTYPE;

	BEGIN

        -- local variables initialization to remove GSCC warnings
        l_media_rec := p_media_rec;

	-- Standard start of API savepoint
		SAVEPOINT update_mediaitem_pub;

			-- Preprocessing Call
			--l_media_rec_hk := p_media_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_MEDIAITEM', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.update_mediaitem_pre(
				                     --p_media_rec=>l_media_rec_hk,
				                     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_MEDIAITEM', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.update_mediaitem_pre(
				                     --p_media_rec=>l_media_rec_hk,
				                     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;



	-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Update_MediaItem');

	-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
			fnd_msg_pub.initialize;
		END IF;

   	-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   	--
	-- Apply business-rule validation to all required and passed parameters
	--
	-- Validate user and login session IDs
	--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
			RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
			  p_parameter_name_usr    => 'p_user_id',
			  p_parameter_name_log    => 'p_login_id',
			  p_user_id         => p_user_id,
			  p_login_id        => p_login_id,
			  x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Update_MediaItem');


		OPEN c_MediaItem_csr;
		FETCH c_MediaItem_csr INTO  l_MediaItem_rec;
		IF (c_MediaItem_csr%notfound) THEN
			x_return_status := fnd_api.g_ret_sts_error;
			jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, to_char(p_media_rec.media_id),
							    'media_id');
			RETURN;
		END IF;
		--
		-- Check if Active is set to 'N'
		--
		IF (l_MediaItem_rec.active = 'N')  then
			--x_return_status := fnd_api.g_ret_sts_error;
			jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, to_char(p_media_rec.media_id),'Active set to N for mediaitem');
			RAISE fnd_api.g_exc_error;
		END IF;
		--
		-- Check if source_id requies updating
		--
		IF (p_media_rec.source_id = fnd_api.g_miss_num) then
			--l_source_id := l_MediaItem_rec.source_id;
			l_media_rec.source_id := l_MediaItem_rec.source_id;
  		ELSE
			l_media_rec.source_id := p_media_rec.source_id;
		END IF;
		--
		-- Check if direction requires updating
		--
		IF (p_media_rec.direction = fnd_api.g_miss_char) then
--			l_direction := l_MediaItem_rec.direction;
			l_media_rec.direction := l_MediaItem_rec.direction;
		ELSE
			l_media_rec.direction := p_media_rec.direction;
		END IF;
		--
		-- Check if end_date_time requires updating
		--
		IF (p_media_rec.start_date_time = fnd_api.g_miss_date) OR (p_media_rec.start_date_time is NULL ) then
			l_media_rec.start_date_time := l_MediaItem_rec.start_date_time;
  		ELSE
			l_media_rec.start_date_time := p_media_rec.start_date_time;
			b_Duration := TRUE;
		END IF;

		--
		-- Check if end_date_time requires updating
		--
		IF (p_media_rec.end_date_time = fnd_api.g_miss_date) then
			--l_end_date_time := l_MediaItem_rec.end_date_time;
			l_media_rec.end_date_time := l_MediaItem_rec.end_date_time;
  		ELSE
			l_media_rec.end_date_time := p_media_rec.end_date_time;
			b_Duration := TRUE;
		END IF;

  		Validate_StartEnd_Date( p_api_name => l_api_name_full,
					p_start_date_time   	=> l_media_rec.start_date_time,
					p_end_date_time		    => l_media_rec.end_date_time,
					x_return_status     	=> l_return_status
				);
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;

		--
		-- Check if duration requires updating
		--
		IF (p_media_rec.duration = fnd_api.g_miss_num) then
			--l_duration := l_MediaItem_rec.duration;
			l_media_rec.duration := l_MediaItem_rec.duration;
  		ELSE
			l_media_rec.duration := p_media_rec.duration;
			b_Duration := FALSE;
		END IF;

  		IF (l_media_rec.duration = fnd_api.g_miss_num)
      		OR (l_media_rec.duration IS NULL) OR (l_media_rec.duration = 0) OR b_Duration THEN
      		l_media_rec.duration := ROUND((l_media_rec.end_date_time - l_media_rec.start_date_time)*24*60*60);
  		END IF;

		--
		-- Check if interaction_performed requires updating
		--
		IF (p_media_rec.interaction_performed = fnd_api.g_miss_char) then
			--l_interaction_performed := l_MediaItem_rec.interaction_performed;
			l_media_rec.interaction_performed := l_MediaItem_rec.interaction_performed;
  ELSE
			l_media_rec.interaction_performed := p_media_rec.interaction_performed;
		END IF;
		--
		-- Check if media_data requires updating
		--
		IF (p_media_rec.media_data = fnd_api.g_miss_char) then
			--l_media_data := l_MediaItem_rec.media_data;
			l_media_rec.media_data := l_MediaItem_rec.media_data;
  ELSE
			l_media_rec.media_data := p_media_rec.media_data;
		END IF;
		--
		-- Check if source_item_create_date_time requires updating
		--
		IF (p_media_rec.source_item_create_date_time = fnd_api.g_miss_date) then
			--l_source_item_create_date_time := l_MediaItem_rec.source_item_create_date_time;
			l_media_rec.source_item_create_date_time := l_MediaItem_rec.source_item_create_date_time;
  ELSE
			l_media_rec.source_item_create_date_time := p_media_rec.source_item_create_date_time;
		END IF;
		--
		-- Check if source_item_id requires updating
		--
		IF (p_media_rec.source_item_id = fnd_api.g_miss_num) then
			--l_source_item_id := l_MediaItem_rec.source_item_id;
			l_media_rec.source_item_id := l_MediaItem_rec.source_item_id;
  ELSE
			l_media_rec.source_item_id := p_media_rec.source_item_id;
		END IF;
		--
		-- Check if media_item_type requires updating
		--
		IF (p_media_rec.media_item_type = fnd_api.g_miss_char) then
			--l_media_item_type := l_MediaItem_rec.media_item_type;
			l_media_rec.media_item_type:= l_MediaItem_rec.media_item_type;
		ELSE
			l_media_rec.media_item_type := p_media_rec.media_item_type;
		END IF;
		--
		-- Check if media_item_ref requires updating
		--
		IF (p_media_rec.media_item_ref = fnd_api.g_miss_char) then
			--l_media_item_ref := l_MediaItem_rec.media_item_ref;
			l_media_rec.media_item_ref := l_MediaItem_rec.media_item_ref;
  ELSE
			l_media_rec.media_item_ref := p_media_rec.media_item_ref;
		END IF;
		--
		-- Check if media_abandon_flag requires updating
		--
		IF (p_media_rec.media_abandon_flag = fnd_api.g_miss_char) then
			--l_media_abandon_flag := l_MediaItem_rec.media_abandon_flag;
			l_media_rec.media_abandon_flag := l_MediaItem_rec.media_abandon_flag;
  ELSE
			l_media_rec.media_abandon_flag := p_media_rec.media_abandon_flag;
		END IF;
		--
		-- Check if media_transferred_flag requires updating
		--
		IF (p_media_rec.media_transferred_flag = fnd_api.g_miss_char) then
			--l_media_transferred_flag := l_MediaItem_rec.media_transferred_flag;
			l_media_rec.media_transferred_flag := l_MediaItem_rec.media_transferred_flag;
  ELSE
			l_media_rec.media_transferred_flag := p_media_rec.media_transferred_flag;
		END IF;
		--
		-- Check if server_group_id requires updating
		--
		IF (p_media_rec.server_group_id = fnd_api.g_miss_num) then
			--l_server_group_id := l_MediaItem_rec.server_group_id;
			l_media_rec.server_group_id := l_MediaItem_rec.server_group_id;
  ELSE
			l_media_rec.server_group_id := p_media_rec.server_group_id;
		END IF;
		--
		-- Check if dnis requires updating
		--
		IF (p_media_rec.dnis = fnd_api.g_miss_char) then
			--l_dnis := l_MediaItem_rec.dnis;
			l_media_rec.dnis := l_MediaItem_rec.dnis;
  ELSE
			l_media_rec.dnis := p_media_rec.dnis;
		END IF;
		--
		-- Check if ani requires updating
		--
		IF (p_media_rec.ani = fnd_api.g_miss_char) then
			--l_ani := l_MediaItem_rec.ani;
			l_media_rec.ani := l_MediaItem_rec.ani;
  ELSE
			l_media_rec.ani := p_media_rec.ani;
		END IF;
		--
		-- Check if classification requires updating
		--
		IF (p_media_rec.classification = fnd_api.g_miss_char) then
			--l_classification := l_MediaItem_rec.classification;
			l_media_rec.classification := l_MediaItem_rec.classification;
  ELSE
			l_media_rec.classification := p_media_rec.classification;
		END IF;

		--
		-- Check if object_version_number requies updating
		--
		IF (p_object_version = fnd_api.g_miss_num)  then
		      l_object_version := l_MediaItem_rec.object_version_number;
  ELSE
		      l_object_version := p_object_version;
		END IF;

  		--
		-- Check if bulk_writer_code requires updating
		--
		IF (p_media_rec.bulk_writer_code = fnd_api.g_miss_char) then
			l_media_rec.bulk_writer_code := l_MediaItem_rec.bulk_writer_code;
  ELSE
			l_media_rec.bulk_writer_code := p_media_rec.bulk_writer_code;
		END IF;

   		--
		-- Check if bulk_batch_type requires updating
		--
		IF (p_media_rec.bulk_batch_type = fnd_api.g_miss_char) then
			l_media_rec.bulk_batch_type := l_MediaItem_rec.bulk_batch_type;
  ELSE
			l_media_rec.bulk_batch_type := p_media_rec.bulk_writer_code;
		END IF;
  		--
		-- Check if bulk_batch_id requires updating
		--
		IF (p_media_rec.bulk_batch_id = fnd_api.g_miss_num) then
			l_media_rec.bulk_batch_id := l_MediaItem_rec.bulk_batch_id;
  ELSE
			l_media_rec.bulk_batch_id := p_media_rec.bulk_batch_id;
		END IF;
  		--
		-- Check if bulk_interaction_id requires updating
		--
		IF (p_media_rec.bulk_interaction_id = fnd_api.g_miss_num) then
			l_media_rec.bulk_interaction_id := l_MediaItem_rec.bulk_interaction_id;
  ELSE
			l_media_rec.bulk_interaction_id := p_media_rec.bulk_interaction_id;
		END IF;

  		--
		-- Check if email_address requires updating
		--

		IF (p_media_rec.address = fnd_api.g_miss_char) THEN
      IF p_media_rec.direction = 'INBOUND' AND p_media_rec.media_item_type LIKE 'TELE%' THEN
    IF p_media_rec.ani <> fnd_api.g_miss_char THEN
        l_media_rec.address := p_media_rec.ani;
    ELSE
        l_media_rec.address := NULL;
    END IF;
      ELSE
    l_media_rec.address :=  l_MediaItem_rec.address;
      END IF;
  ELSE
			l_media_rec.address := p_media_rec.address;
		END IF;

		--
		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Media_Item
		(	p_api_name      => l_api_name_full,
			p_media_item_val      => l_media_rec,
			p_resp_appl_id  => p_resp_appl_id,
			p_resp_id       => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST Validate_MediaItem_Record in JTF_IH_PUB.Update_MediaItem');

		UPDATE JTF_IH_MEDIA_ITEMS
			SET	source_id		=	l_media_rec.source_id,
				direction		=	l_media_rec.direction,
				duration		=	l_media_rec.duration,
				end_date_time		=	l_media_rec.end_date_time,
				interaction_performed	=	l_media_rec.interaction_performed,
				start_date_time		=	l_media_rec.start_date_time,
				media_data		=	decode( l_media_rec.media_data, fnd_api.g_miss_char, null, l_media_rec.media_data),
				source_item_create_date_time = l_media_rec.source_item_create_date_time,
				source_item_id		=	l_media_rec.source_item_id,
				media_item_type		=	l_media_rec.media_item_type,
				media_item_ref		=	l_media_rec.media_item_ref,
				media_abandon_flag	=	l_media_rec.media_abandon_flag,
				media_transferred_flag	=	l_media_rec.media_transferred_flag,
    -- Bug# 2338832
    server_group_id     =   decode(l_media_rec.server_group_id,fnd_api.g_miss_num,null, l_media_rec.server_group_id),
    dnis    =   decode(l_media_rec.dnis, fnd_api.g_miss_char, null, l_media_rec.dnis),
    ani     =   decode(l_media_rec.ani, fnd_api.g_miss_char, null, l_media_rec.ani),
    classification      =   decode(l_media_rec.classification, fnd_api.g_miss_char, null, l_media_rec.classification),
				last_update_date	=	sysdate,
				last_updated_by		=	p_user_id,
				last_update_login	=	p_login_id,
    object_version_number = l_object_version,
    BULK_WRITER_CODE    =   l_media_rec.bulk_writer_code,
    BULK_BATCH_TYPE     =   l_media_rec.bulk_batch_type,
    BULK_BATCH_ID       =   l_media_rec.bulk_batch_id,
    BULK_INTERACTION_ID =   l_media_rec.bulk_interaction_id,
    ADDRESS       =   decode(l_media_rec.address,fnd_api.g_miss_char, null, l_media_rec.address)
			WHERE CURRENT OF c_MediaItem_csr;
		--
		-- Close Cursor
		--
		Close c_MediaItem_csr;
		--

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_MEDIAITEM', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.update_mediaitem_post(
				                     --p_media_rec=>l_media_rec_hk,
				                     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_MEDIAITEM', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.update_mediaitem_post(
				                     --p_media_rec=>l_media_rec_hk,
				                     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


		-- Standard check of p_commit
		--
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;
		--
		-- Standard call to get message count and if count is 1, get message info
		--
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO Update_mediaitem_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO Update_mediaitem_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO Update_mediaitem_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Update_MediaItem;


--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	James Baldo Jr.	15-MAR-2000	Initial Version after losing file
--	James Baldo Jr.	21-APR-2000	Active setting defect based on bugdb# 127726
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--	James Baldo Jr.	28-JUL-2000	Fix for bugdb # 1340013 for initializing end_date_time
--					when not set by client.
--	James Baldo Jr. 30-NOV-2000	Logic for two new columns, Media_Abandon_Flag and Media_Transferred_Flag.
--					Enhancement Bugdb # 1501325
--  Igor Aleshin    18-DEC-2001 Bug# 2153913 - PREVENT G_MISS_DATE VALUE FROM BEING WRITTEN TO
--            THE END_DATE_TIME VALUE.
--  Igor Aleshin    21-MAY-2002 Changed setup procedure for End_Date_Time.
--  Igor Aleshin    29-MAY-2003 Enh# 2940473 - IH Bulk API Changes
--  Igor Aleshin    16-JUL-2003 Enh# 3045626 - Clean-Up Close_MediaItem Update Logic
--  Igor Aleshin    08-Mar-2004 Enh# 3491849 - JTH.R: IH CHANGES TO SUPPORT FTC ABANDONMENT REGULATIONS
--  vekrishn        27-JUL-2004 Perf Fix for literal Usage
--
--

	PROCEDURE Close_MediaItem
	(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id		IN	NUMBER		DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_media_rec		IN media_rec_type,
    p_object_version IN NUMBER DEFAULT NULL
	) AS
		l_api_name   		CONSTANT VARCHAR2(30) := 'Close_MediaItem';
		l_api_version      	CONSTANT NUMBER       := 1.0;
		l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		l_return_status    	VARCHAR2(1);
		l_source_id	    	NUMBER(15);
		l_count	    		NUMBER := 0;
		l_media_data	    VARCHAR2(80);
		l_end_date_time    	DATE := NULL;
  -- Added by IAleshin 21-MAY-2002
		--l_start_date_time   DATE := NULL;
                --l_duration    		NUMBER;
  --
		l_media_lc_rec  	media_lc_rec_type;
		l_return_code		VARCHAR2(1);
		l_data				VARCHAR2(2000);
		l_count_hk			NUMBER;
		l_media_rec			MEDIA_REC_TYPE;

		l_ao_update_pending VARCHAR2(1);
        l_soft_closed  		VARCHAR2(1);
        l_direction			VARCHAR2(256);
        l_media_item_type	VARCHAR2(256);

  -- Perf fix for literal Usage
  l_active_perf            VARCHAR2(1);
  l_soft_closed_perf       VARCHAR2(1);

		 CURSOR c_media_item_lc_segs IS
		 	SELECT *
		 	FROM jtf_ih_media_item_lc_segs
		 	WHERE media_id = p_media_rec.media_id;
	BEGIN
		-- Standard start of API savepoint
		SAVEPOINT close_mediaitem_pub1;

   -- Perf variables
   l_active_perf := 'N';
   l_soft_closed_perf := 'Y';

			-- Preprocessing Call
			l_media_rec := p_media_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_MEDIAITEM', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.close_mediaitem_pre(
				                     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_MEDIAITEM', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.close_mediaitem_pre(
				                     p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Close_MediaItem');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
			fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info(
				p_api_name        => l_api_name_full,
				p_parameter_name_usr    => 'p_user_id',
				p_parameter_name_log    => 'p_login_id',
				p_user_id         => p_user_id,
				p_login_id        => p_login_id,
				x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;


  	-- Enh# 3491849
  	--
    -- Get current values for ao_update_pending and soft_closed columns and end_date_time
    --
   	SELECT ao_update_pending,  direction, media_item_type, end_date_time
        INTO l_ao_update_pending, l_direction, l_media_item_type, l_end_date_time
        FROM JTF_IH_MEDIA_ITEMS WHERE Media_Id = p_media_rec.media_id;

  -- Check end_date_time parameter.
  --
  IF p_media_rec.end_date_time <> fnd_api.g_miss_date AND p_media_rec.end_date_time IS NOT NULL THEN
      l_media_rec.end_date_time := p_media_rec.end_date_time;
  ELSE
      IF l_end_date_time IS NOT NULL AND l_end_date_time <> fnd_api.g_miss_date THEN
      l_media_rec.end_date_time := l_end_date_time;
    ELSE
    	l_media_rec.end_date_time := SYSDATE;
	END IF;
  END IF;
		--
		--Update MediaItem
		--
		Update_MediaItem(
					p_api_version,
					p_init_msg_list,
					'F',         -- No Commit.
					p_resp_appl_id,
					p_resp_id,
					p_user_id,
					p_login_id,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_media_rec,
        			p_object_version);
		IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST Update_MediaItem in JTF_IH_PUB.Close_MediaItem');
		--
  	-- Enh# 3491849
  	--
  	IF l_direction = 'OUTBOUND' AND l_media_item_type = 'TELEPHONE' THEN
		IF l_ao_update_pending = 'Y' THEN
			--  Soft close the MI
			UPDATE JTF_IH_MEDIA_ITEMS
			SET SOFT_CLOSED = l_soft_closed_perf
			WHERE MEDIA_ID = p_media_rec.media_id;
		ELSE
			-- hard close the MI
			UPDATE JTF_IH_MEDIA_ITEMS
			SET ACTIVE = l_active_perf
			WHERE MEDIA_ID = p_media_rec.media_id;
		END IF;
	ELSE
		-- hard close the MI
		UPDATE JTF_IH_MEDIA_ITEMS
		set ACTIVE = l_active_perf
		WHERE MEDIA_ID = p_media_rec.media_id;
	END IF;

  -- Close all related Media_Item_LCs
  --
  FOR cur_Milcs IN (SELECT milcs_id, start_date_time, end_date_time, duration
          FROM jtf_ih_media_item_lc_segs WHERE Media_Id = p_media_rec.media_id) LOOP
      IF (cur_Milcs.end_date_time IS NULL) OR (cur_Milcs.end_date_time = fnd_api.g_miss_date) THEN
    		cur_Milcs.end_date_time := l_end_date_time;
		    Validate_StartEnd_Date
			   (  p_api_name    => l_api_name_full,
				  p_start_date_time   => cur_Milcs.start_date_time,
				  p_end_date_time		=> cur_Milcs.end_date_time,
				  x_return_status     => l_return_status);
		      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			     RAISE fnd_api.g_exc_error;
		      END IF;
    		-- If we already have duration then pass previouse value without modification
    		-- else calculate new duration value
    	IF (cur_Milcs.duration IS NULL) OR (cur_Milcs.duration = 0) THEN
        	cur_Milcs.duration := ROUND((cur_Milcs.end_date_time - cur_Milcs.start_date_time)*24*60*60);
    	END IF;
      END IF;

        UPDATE JTF_IH_MEDIA_ITEM_LC_SEGS SET
			End_Date_Time = cur_Milcs.end_date_time,
        	Start_Date_time = cur_Milcs.start_date_time,
        	Duration = cur_Milcs.duration,
        	Active = l_active_perf
        	WHERE milcs_id = cur_Milcs.milcs_id;
  END LOOP;
			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_MEDIAITEM', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.close_mediaitem_post(p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'CLOSE_MEDIAITEM', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.close_mediaitem_post(p_media_rec=>l_media_rec,
						     x_data=>l_data,
						     x_count=>l_count_hk,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;


		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;
		--
		-- Standard check of p_commit
		--
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;
		--
		-- Standard call to get message count and if count is 1, get message info
		--
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO close_mediaitem_pub1;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO close_mediaitem_pub1;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO close_mediaitem_pub1;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Close_MediaItem;

--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	James Baldo Jr.	15-MAR-2000	Initial Version after losing file
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--  Igor Aleshin    18-DEC-2001 Bug# 2153913 - PREVENT G_MISS_DATE VALUE FROM BEING WRITTEN TO
--            THE END_DATE_TIME VALUE.
--  Igor Aleshin    20-MAY-2002 Changed duration calculation
--  Igor Aleshin    24-FEB-2003 Fixed bug# 2817083 - Error loggin interactions

--

	PROCEDURE Add_MediaLifecycle
	(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_media_lc_rec	IN	media_lc_rec_type,
	x_milcs_id	OUT NOCOPY	NUMBER
	) AS
		l_api_name   	CONSTANT VARCHAR2(30) := 'Open_MediaLifeCycle';
		l_api_version      	CONSTANT NUMBER       := 1.0;
		l_api_name_full    	CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
		l_return_status    	VARCHAR2(1);
		--l_milcs_id		NUMBER;
		--l_start_date_time	DATE;
  -- Bug# 2153913
		--l_end_date_time	    DATE;
		l_active		VARCHAR2(1);
		--l_duration		NUMBER := NULL;
		l_media_lc_rec		media_lc_rec_type;
		--l_media_lc_rec_hk	media_lc_rec_type;
		l_return_code		VARCHAR2(1);
		l_data			VARCHAR2(2000);
		l_count			NUMBER;
		--l_milcs_type_id		NUMBER := NULL;

	BEGIN
                -- local variables initialization to remove GSCC warning
                l_active := 'Y';
                l_media_lc_rec := p_media_lc_rec;

		--
		-- Standard start of API savepoint
		--
		SAVEPOINT open_medialifecycle_pub;

			-- Preprocessing Call
			--l_media_lc_rec_hk := p_media_lc_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'ADD_MEDIALIFECYCLE', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.add_medialifecycle_pre(
				                     --p_media_lc_rec=>l_media_lc_rec_hk,
				                     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'ADD_MEDIALIFECYCLE', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.add_medialifecycle_pre(
				                     --p_media_lc_rec=>l_media_lc_rec_hk,
				                     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		--
		-- Standard call to check for call compatibility
		--
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Add_MediaLifeCycle');
		--
		-- Initialize message list if p_init_msg_list is set to TRUE
		--
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		fnd_msg_pub.initialize;
		END IF;
		--
   		-- Initialize API return status to success
   		--
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
				RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
			  p_parameter_name_usr    => 'p_user_id',
			  p_parameter_name_log    => 'p_login_id',
			  p_user_id         => p_user_id,
			  p_login_id        => p_login_id,
			  x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Add_MediaLifeCycle');

		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Mlcs_Record
		(	p_api_name      => l_api_name_full,
			p_media_lc_rec  => p_media_lc_rec,
			p_resp_appl_id  => p_resp_appl_id,
			p_resp_id       => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST Validate_Media_LC_Record in JTF_IH_PUB.Add_MediaLifeCycle');
		-- assign milcs_type_id if not supplied
		-- since milcs_code has been validate previously no checking is required.
		IF ((p_media_lc_rec.milcs_type_id IS NULL)  OR (p_media_lc_rec.milcs_type_id = fnd_api.g_miss_num)) THEN
			select milcs_type_id
			--INTO l_milcs_type_id
			INTO   l_media_lc_rec.milcs_type_id
			from JTF_IH_MEDIA_ITM_LC_SEG_TYS
			where milcs_code = p_media_lc_rec.milcs_code;
		ELSE
			--l_milcs_type_id := p_media_lc_rec.milcs_type_id;
			l_media_lc_rec.milcs_type_id := p_media_lc_rec.milcs_type_id;
		END IF;

  -- Modified by IAleshin 20-MAY-2002
		-- assign the end_date_time
		IF(p_media_lc_rec.end_date_time IS NOT NULL) AND (p_media_lc_rec.end_date_time <> fnd_api.g_miss_date) THEN
			--l_end_date_time := p_media_lc_rec.end_date_time;
			l_media_lc_rec.end_date_time := p_media_lc_rec.end_date_time;
		ELSE
			--l_end_date_time := NULL;
			l_media_lc_rec.end_date_time := NULL;
                        --l_duration := NULL;
                        l_media_lc_rec.duration := NULL;
		END IF;

		-- assign the start_date_time
		IF(p_media_lc_rec.start_date_time IS NOT NULL) AND (p_media_lc_rec.start_date_time <> fnd_api.g_miss_date) THEN
			--l_start_date_time := p_media_lc_rec.start_date_time;
			l_media_lc_rec.start_date_time := p_media_lc_rec.start_date_time;
		ELSE
			--l_start_date_time := SYSDATE;
			l_media_lc_rec.start_date_time := SYSDATE;
		END IF;

			Validate_StartEnd_Date
			(	p_api_name    => l_api_name_full,
				--p_start_date_time   => l_start_date_time,
				p_start_date_time   => l_media_lc_rec.start_date_time,
				--p_end_date_time	    => l_end_date_time,
				p_end_date_time	    => l_media_lc_rec.end_date_time,
				x_return_status     => l_return_status
			);
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;

		-- assign the duration
		IF(p_media_lc_rec.duration IS NOT NULL) AND (p_media_lc_rec.duration <> fnd_api.g_miss_num) THEN
			--l_duration := p_media_lc_rec.duration;
			l_media_lc_rec.duration := p_media_lc_rec.duration;
		ELSIF (l_media_lc_rec.end_date_time IS NULL) THEN
                        --l_duration := 0;
                        l_media_lc_rec.duration := 0;
  ELSE
			--l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
			l_media_lc_rec.duration := ROUND((l_media_lc_rec.end_date_time - l_media_lc_rec.start_date_time)*24*60*60);
		END IF;

		-- DBMS_OUTPUT.PUT_LINE('PAST assign the duration in JTF_IH_PUB.Add_MediaLifeCycle');

  -- Bug# 2817083
		--SELECT JTF_IH_MEDIA_ITEM_LC_SEG_S1.NextVal into l_milcs_id FROM dual;
		-- DBMS_OUTPUT.PUT_LINE('PAST generated sequence JTF_IH_PUB.Add_MediaLifeCycle milcs := ' || l_milcs_id);
  --l_milcs_id := Get_milcs_id(NULL);
  l_media_lc_rec.milcs_id := Get_milcs_id(NULL);

		INSERT INTO jtf_ih_media_item_lc_segs
		(
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN,
			 MILCS_ID,
			 START_DATE_TIME,
			 TYPE_TYPE,
			 TYPE_ID,
			 DURATION,
			 END_DATE_TIME,
			 MILCS_TYPE_ID,
			 MEDIA_ID,
			 HANDLER_ID,
			 RESOURCE_ID,
			 ACTIVE
			)
			VALUES
			(
			 p_user_id,
			 Sysdate,
			 p_user_id,
			 Sysdate,
			 p_login_id,
			 --l_milcs_id,
			 l_media_lc_rec.milcs_id,
			 --l_start_date_time,
			 l_media_lc_rec.start_date_time,
			 decode(p_media_lc_rec.type_type,fnd_api.g_miss_char, null, p_media_lc_rec.type_type),
			 decode(p_media_lc_rec.type_id,fnd_api.g_miss_num, null, p_media_lc_rec.type_id),
			 --l_duration,
			 l_media_lc_rec.duration,
			 --l_end_date_time,
			 l_media_lc_rec.end_date_time,
			 --l_milcs_type_id,
			 l_media_lc_rec.milcs_type_id,
			 l_media_lc_rec.media_id,
			 l_media_lc_rec.handler_id,
			 decode(l_media_lc_rec.resource_id,fnd_api.g_miss_num, null, l_media_lc_rec.resource_id),
			 l_active
			);
		-- DBMS_OUTPUT.PUT_LINE('PAST INSERT INTO Validate_Media_LC_Record in JTF_IH_PUB.Add_MediaLifeCycle');

		--
		-- Set OUT value
		--
		--x_milcs_id := l_milcs_id;
		x_milcs_id := l_media_lc_rec.milcs_id;

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'ADD_MEDIALIFECYCLE', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.add_medialifecycle_post(
				                     --p_media_lc_rec=>l_media_lc_rec_hk,
				                     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'ADD_MEDIALIFECYCLE', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.add_medialifecycle_post(
				                     --p_media_lc_rec=>l_media_lc_rec_hk,
				                     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;



		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO open_medialifecycle_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO open_medialifecycle_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO open_medialifecycle_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
      x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Add_MediaLifecycle;

--
--	HISTORY
--
--	AUTHOR		DATE		MODIFICATION DESCRIPTION
--	------		----		--------------------------
--
--	James Baldo Jr.	15-MAR-2000	Initial Version after losing file
--	James Baldo Jr.	21-APR-2000	For Active setting defect based on bugdb# 1277244
--	James Baldo Jr.	25-APR-2000	User Hooks Customer and Vertical Industry
--  Igor Aleshin    29-MAY-2003 Enh# 2940473 - IH Bulk API Changes
--
--

	PROCEDURE Update_MediaLifecycle
	(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count	OUT NOCOPY	NUMBER,
	x_msg_data	OUT NOCOPY	VARCHAR2,
	p_media_lc_rec	IN	media_lc_rec_type,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL
	) AS
	l_api_name   			CONSTANT VARCHAR2(30) := 'Update_MediaLifecycle';
	l_api_version      			CONSTANT NUMBER       := 1.0;
	l_api_name_full    			CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
	l_return_status    			VARCHAR2(1);
	l_milcs_id				NUMBER;
	l_media_id				NUMBER;
	--l_type_id				NUMBER;
	--l_duration				NUMBER;
	--l_end_date_time				DATE;
	--l_start_date_time			DATE;
	--l_milcs_type_id				NUMBER;
	l_type_type				VARCHAR2(80);
	l_handler_id				NUMBER;
	l_resource_id				NUMBER;
	l_active				VARCHAR2(1);
	l_media_lc_rec				media_lc_rec_type;
	--l_media_lc_rec_hk			media_lc_rec_type;
	l_return_code				VARCHAR2(1);
	l_data					VARCHAR2(2000);
	l_count					NUMBER;
    l_object_version  NUMBER;
    l_bulk_writer_code      VARCHAR2(240);
    l_bulk_batch_type       VARCHAR2(240);
    l_bulk_batch_id   NUMBER;
    l_bulk_interaction_id   NUMBER;

	CURSOR c_Update_MediaLifecycle_csr IS
		SELECT *
		FROM 	JTF_IH_MEDIA_ITEM_LC_SEGS
		WHERE 	milcs_id = p_media_lc_rec.milcs_id
		FOR UPDATE;
	v_Update_MediaLifecycle_rec	c_Update_MediaLifecycle_csr%ROWTYPE;

	BEGIN
               -- local variables initialization to remove GSCC warnings
               --l_type_id :=fnd_api.g_miss_num;
               --l_duration :=fnd_api.g_miss_num;
               --l_end_date_time :=fnd_api.g_miss_date;
               --l_start_date_time :=fnd_api.g_miss_date;
               --l_milcs_type_id :=fnd_api.g_miss_num;
               l_type_type :=fnd_api.g_miss_char;
               l_handler_id :=fnd_api.g_miss_num;
               l_resource_id :=fnd_api.g_miss_num;
               l_active :=NULL;
               l_media_lc_rec :=p_media_lc_rec;

                        -- Standard start of API savepoint
		        SAVEPOINT update_medialifecycle_pub;

			-- Preprocessing Call
			--l_media_lc_rec_hk := p_media_lc_rec;
			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_MEDIALIFECYCLE', 'B', 'C') THEN
				JTF_IH_PUB_CUHK.update_medialifecycle_pre(
				                     --p_media_lc_rec=>l_media_lc_rec_hk,
				                     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_MEDIALIFECYCLE', 'B', 'V') THEN
				JTF_IH_PUB_VUHK.update_medialifecycle_pre(
				                     --p_media_lc_rec=>l_media_lc_rec_hk,
				                     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

		-- Standard call to check for call compatibility
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
              l_api_name, g_pkg_name) THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST fnd_api.compatible_api_call in JTF_IH_PUB.Update_MediaLifecycle');

		-- Initialize message list if p_init_msg_list is set to TRUE
		IF fnd_api.to_boolean(p_init_msg_list) THEN
			fnd_msg_pub.initialize;
		END IF;

   		-- Initialize API return status to success
   		x_return_status := fnd_api.g_ret_sts_success;

   		--
		-- Apply business-rule validation to all required and passed parameters
		--
		-- Validate user and login session IDs
		--
		IF (p_user_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
			RAISE fnd_api.g_exc_error;
		ELSE
			jtf_ih_core_util_pvt.validate_who_info
			( p_api_name        => l_api_name_full,
			  p_parameter_name_usr    => 'p_user_id',
			  p_parameter_name_log    => 'p_login_id',
			  p_user_id         => p_user_id,
			  p_login_id        => p_login_id,
			  x_return_status   => l_return_status );
			IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_error;
			END IF;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST jtf_ih_core_util_pvt.validate_who_info in JTF_IH_PUB.Update_MediaLifecycle');

		IF (p_media_lc_rec.milcs_id IS NULL) THEN
			jtf_ih_core_util_pvt.add_null_parameter_msg(l_api_name_full, 'milcs_id');
			RAISE fnd_api.g_exc_error;
		ELSE

			OPEN c_Update_MediaLifecycle_csr;
			FETCH c_Update_MediaLifecycle_csr INTO  v_Update_MediaLifecycle_rec;
			IF (c_Update_MediaLifecycle_csr%notfound) THEN
				x_return_status := fnd_api.g_ret_sts_error;
				jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, to_char(p_media_lc_rec.milcs_id),
							    'media_id');
				RETURN;
			END IF;
			-- DBMS_OUTPUT.PUT_LINE('PAST OPEN c_Update_MediaLifecycle_csr in JTF_IH_PUB.Update_MediaLifecycle');

			IF(v_Update_MediaLifecycle_rec.active <> 'N') THEN
				--
				-- Check if start_date_time requires updating
				--
				IF ((p_media_lc_rec.start_date_time IS NULL) OR (p_media_lc_rec.start_date_time = fnd_api.g_miss_date)) then
					--l_start_date_time := v_Update_MediaLifecycle_rec.start_date_time;
					l_media_lc_rec.start_date_time := v_Update_MediaLifecycle_rec.start_date_time;
				ELSE
					--l_start_date_time := p_media_lc_rec.start_date_time;
					l_media_lc_rec.start_date_time := p_media_lc_rec.start_date_time;
				END IF;
				--
				-- Check if end_date_time requires updating
				--
				IF ((p_media_lc_rec.end_date_time IS NULL) OR (p_media_lc_rec.end_date_time = fnd_api.g_miss_date)) THEN
					IF ((v_Update_MediaLifecycle_rec.end_date_time IS NULL) OR (v_Update_MediaLifecycle_rec.end_date_time = fnd_api.g_miss_date)) THEN
						--l_end_date_time := sysdate;
						l_media_lc_rec.end_date_time := sysdate;
					ELSE
						--l_end_date_time := v_Update_MediaLifecycle_rec.end_date_time;
						l_media_lc_rec.end_date_time := v_Update_MediaLifecycle_rec.end_date_time;
					END IF;
				ELSE
					--l_end_date_time := p_media_lc_rec.end_date_time;
					l_media_lc_rec.end_date_time := p_media_lc_rec.end_date_time;
				END IF;

				Validate_StartEnd_Date
						(	p_api_name    => l_api_name_full,
							--p_start_date_time   => l_start_date_time,
							p_start_date_time   => l_media_lc_rec.start_date_time,
							--p_end_date_time	    => l_end_date_time,
							p_end_date_time	    => l_media_lc_rec.end_date_time,
							x_return_status     => l_return_status
						);
				IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
					--DBMS_OUTPUT.PUT_LINE('Error in Validate_StartEnd_Date of JTF_IH_PUB.Update_MediaLifecycle');
					RAISE fnd_api.g_exc_error;
				END IF;
				--
				-- Check if  duration requires updating
				--
				IF ((p_media_lc_rec.duration IS NULL) OR (p_media_lc_rec.duration = fnd_api.g_miss_num)) THEN
				    --l_duration := v_Update_MediaLifecycle_rec.duration;
				    l_media_lc_rec.duration := v_Update_MediaLifecycle_rec.duration;
				ELSE
				    --l_duration := ROUND((l_end_date_time - l_start_date_time)*24*60*60);
				    l_media_lc_rec.duration := ROUND((l_media_lc_rec.end_date_time - l_media_lc_rec.start_date_time)*24*60*60);
				END IF;

				--
				-- Validate start_date_time and end_date_time by calling the utility procedure.
				--
				--DBMS_OUTPUT.PUT_LINE('PAST Validate_StartEnd_Date in JTF_IH_PUB.Update_MediaLifecycle');
			ELSE
				-- DBMS_OUTPUT.PUT_LINE('hello active error in JTF_IH_PUB.Update_MediaLifecycle');
				jtf_ih_core_util_pvt.add_invalid_argument_msg(l_api_name, to_char(p_media_lc_rec.milcs_id),'Active set to N for medialifecycle');
				RAISE fnd_api.g_exc_error;
			END IF;
				--
				-- Check if type_type requies updating
				--
				-- DBMS_OUTPUT.PUT_LINE('l_type_type1 p_media_lc_rec.type_type := ' || p_media_lc_rec.type_type);
				-- DBMS_OUTPUT.PUT_LINE('l_type_type1 v_Update_MediaLifecycle_rec.type_type := ' || v_Update_MediaLifecycle_rec.type_type);
				IF (p_media_lc_rec.type_type = fnd_api.g_miss_char) then
					-- DBMS_OUTPUT.PUT_LINE('l_type_type2 := ');
					-- DBMS_OUTPUT.PUT_LINE('l_type_type2 := ' || v_Update_MediaLifecycle_rec.type_type);
					--l_type_type := v_Update_MediaLifecycle_rec.type_type;
					l_media_lc_rec.type_type := v_Update_MediaLifecycle_rec.type_type;
				ELSE
					-- DBMS_OUTPUT.PUT_LINE('l_type_type3' || p_media_lc_rec.type_type);
					--l_type_type := p_media_lc_rec.type_type;
					l_media_lc_rec.type_type := p_media_lc_rec.type_type;
				END IF;
				--
				-- Check if type_id requires updating
				--
				-- DBMS_OUTPUT.PUT_LINE('l_type_id');
				IF (p_media_lc_rec.type_id = fnd_api.g_miss_num) then
					--l_type_id := v_Update_MediaLifecycle_rec.type_id;
					l_media_lc_rec.type_id := v_Update_MediaLifecycle_rec.type_id;
				ELSE
					--l_type_id := p_media_lc_rec.type_id;
					l_media_lc_rec.type_id := p_media_lc_rec.type_id;
				END IF;
				--
				-- Check if milcs_type_id requires updating
				--
				-- DBMS_OUTPUT.PUT_LINE('l_milcs_type_id');
				IF (p_media_lc_rec.milcs_type_id = fnd_api.g_miss_num) then
					--l_milcs_type_id := v_Update_MediaLifecycle_rec.milcs_type_id;
					l_media_lc_rec.milcs_type_id := v_Update_MediaLifecycle_rec.milcs_type_id;

				ELSE
					--l_milcs_type_id := p_media_lc_rec.milcs_type_id;
					l_media_lc_rec.milcs_type_id := p_media_lc_rec.milcs_type_id;
				END IF;
				--
				-- Check if handler_id requires updating
				--
				-- DBMS_OUTPUT.PUT_LINE('l_handler_id');
				IF (p_media_lc_rec.handler_id = fnd_api.g_miss_num) then
					--l_handler_id := v_Update_MediaLifecycle_rec.handler_id;
					l_media_lc_rec.handler_id := v_Update_MediaLifecycle_rec.handler_id;

				ELSE
					l_handler_id := p_media_lc_rec.handler_id;
					l_media_lc_rec.handler_id := p_media_lc_rec.handler_id;
				END IF;
				--
				-- Check if resource_id requires updating
				--
				-- DBMS_OUTPUT.PUT_LINE('l_resource_id');
				IF (p_media_lc_rec.resource_id = fnd_api.g_miss_num) then
					--l_resource_id := v_Update_MediaLifecycle_rec.resource_id;
					l_media_lc_rec.resource_id := v_Update_MediaLifecycle_rec.resource_id;

				ELSE
					--l_resource_id := p_media_lc_rec.resource_id;
					l_media_lc_rec.resource_id := p_media_lc_rec.resource_id;
				END IF;
				-- DBMS_OUTPUT.PUT_LINE('Before UPDATE JTF_IH_MEDIA_ITEM_LC_SEGS in JTF_IH_PUB.Update_MediaLifecycle');
		  --
		  -- Check if object_version_number requies updating
		  --
		  IF (p_object_version IS NULL)  then
		        l_object_version := v_Update_MediaLifecycle_rec.object_version_number;
		  ELSE
		        l_object_version := p_object_version;
		  END IF;


		  --
		  -- Check if bulk_writer_code requies updating
		  --
		  IF (p_media_lc_rec.bulk_writer_code IS NULL)  then
		        l_bulk_writer_code := v_Update_MediaLifecycle_rec.bulk_writer_code;
		  ELSE
		        l_bulk_writer_code := p_media_lc_rec.bulk_writer_code;
		  END IF;
		  --
		  -- Check if bulk_writer_code requies updating
		  --
		  IF (p_media_lc_rec.bulk_batch_type IS NULL)  then
		        l_bulk_batch_type := v_Update_MediaLifecycle_rec.bulk_batch_type;
		  ELSE
		        l_bulk_batch_type := p_media_lc_rec.bulk_batch_type;
		  END IF;

		  --
		  -- Check if bulk_batch_id requies updating
		  --
		  IF (p_media_lc_rec.bulk_batch_id IS NULL)  then
		        l_bulk_batch_id := v_Update_MediaLifecycle_rec.bulk_batch_id;
		  ELSE
		        l_bulk_batch_id := p_media_lc_rec.bulk_batch_id;
		  END IF;
		  --
		  -- Check if bulk_interaction_id requies updating
		  --
		  IF (p_media_lc_rec.bulk_interaction_id IS NULL)  then
		        l_bulk_interaction_id := v_Update_MediaLifecycle_rec.bulk_writer_code;
		  ELSE
		        l_bulk_interaction_id := p_media_lc_rec.bulk_interaction_id;
		  END IF;
		--
		-- Validate all non-missing attributes by calling the utility procedure.
		--
		Validate_Mlcs_Record
		(	p_api_name      => l_api_name_full,
			p_media_lc_rec  => l_media_lc_rec,
			p_resp_appl_id  => p_resp_appl_id,
			p_resp_id       => p_resp_id,
			x_return_status       => l_return_status
		);
		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_error;
		END IF;
		-- DBMS_OUTPUT.PUT_LINE('PAST Validate_MediaItem_Record in JTF_IH_PUB.Update_MediaLifecycle');


				UPDATE JTF_IH_MEDIA_ITEM_LC_SEGS
				SET
					handler_id		=	l_media_lc_rec.handler_id,
					resource_id		=	l_media_lc_rec.resource_id,
					duration		=	decode( l_media_lc_rec.duration, fnd_api.g_miss_num, 0,l_media_lc_rec.duration),
					end_date_time		=	l_media_lc_rec.end_date_time,
					start_date_time		=	l_media_lc_rec.start_date_time,
					type_type		=	decode( l_media_lc_rec.type_type, fnd_api.g_miss_char, null,l_media_lc_rec.type_type),
					type_id 		= 	decode( l_media_lc_rec.type_id, fnd_api.g_miss_num, null,l_media_lc_rec.type_id),
					milcs_type_id		=	decode( l_media_lc_rec.milcs_type_id, fnd_api.g_miss_num, null,l_media_lc_rec.milcs_type_id),
					last_update_date	=	sysdate,
					last_updated_by		=	p_user_id,
					last_update_login	=	p_login_id,
        object_version_number = l_object_version,
        bulk_writer_code    =   decode( l_bulk_writer_code, fnd_api.g_miss_char, null, l_bulk_writer_code),
        bulk_batch_type     =   decode( l_bulk_batch_type, fnd_api.g_miss_char, null, l_bulk_batch_type),
        bulk_batch_id       =   decode( l_bulk_batch_id, fnd_api.g_miss_num, null, l_bulk_batch_id),
        bulk_interaction_id =   decode( l_bulk_interaction_id, fnd_api.g_miss_num, null, l_bulk_interaction_id)
				WHERE CURRENT OF c_Update_MediaLifecycle_csr;
			END IF;

			-- Post processing Call

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_MEDIALIFECYCLE', 'A', 'V') THEN
				JTF_IH_PUB_VUHK.update_medialifecycle_post(
				                     --p_media_lc_rec=>l_media_lc_rec_hk,
				                     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;

			IF JTF_USR_HKS.Ok_TO_EXECUTE('JTF_IH_PUB', 'UPDATE_MEDIALIFECYCLE', 'A', 'C') THEN
				JTF_IH_PUB_CUHK.update_medialifecycle_post(
				                     --p_media_lc_rec=>l_media_lc_rec_hk,
				                     p_media_lc_rec=>l_media_lc_rec,
						     x_data=>l_data,
						     x_count=>l_count,
						     x_return_code=>l_return_code);
				IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;



		-- Standard check of p_commit
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info
		fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data   => x_msg_data );
		EXCEPTION
		WHEN fnd_api.g_exc_error THEN
			ROLLBACK TO update_medialifecycle_pub;
			x_return_status := fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
    x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN fnd_api.g_exc_unexpected_error THEN
			ROLLBACK TO update_medialifecycle_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
    x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
		WHEN OTHERS THEN
			ROLLBACK TO update_medialifecycle_pub;
			x_return_status := fnd_api.g_ret_sts_unexp_error;
			IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
				fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
			END IF;
			fnd_msg_pub.count_and_get
				( p_count       => x_msg_count,
				p_data  => x_msg_data );
    x_msg_data := FND_MSG_PUB.Get(p_msg_index => x_msg_count, p_encoded=>'F');
	END Update_MediaLifecycle;



FUNCTION INIT_INTERACTION_REC RETURN interaction_rec_type
AS

l_interaction_rec_type interaction_rec_type;

BEGIN

return l_interaction_rec_type;

END INIT_INTERACTION_REC;

FUNCTION INIT_ACTIVITY_REC RETURN activity_rec_type
AS

l_activity_rec_type activity_rec_type;

BEGIN

return l_activity_rec_type;

END INIT_ACTIVITY_REC;

END JTF_IH_PUB;


/
