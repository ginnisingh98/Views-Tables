--------------------------------------------------------
--  DDL for Package Body CSI_INSTANCE_PARTIES_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_INSTANCE_PARTIES_VLD_PVT" AS
/* $Header: csivipvb.pls 120.1.12010000.4 2009/08/05 22:21:06 lakmohan ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'CSI_INSTANCE_PARTIES_VLD_PVT';
/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param_num
(
	p_number                IN      NUMBER,
	p_param_name            IN      VARCHAR2,
	p_api_name              IN      VARCHAR2
) IS
BEGIN
	IF (NVL(p_number,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) THEN
		FND_MESSAGE.SET_NAME('CSI','CSI_API_REQD_PARAM_MISSING');
		FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
		FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
END Check_Reqd_Param_num;

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param_char
(
	p_variable      IN      VARCHAR2,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
) IS
BEGIN
	IF (NVL(p_variable,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) THEN
	    FND_MESSAGE.SET_NAME('CSI','CSI_API_REQD_PARAM_MISSING');
    	    FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
	    FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
	    FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
	END IF;
END Check_Reqd_Param_char;

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param_date
(
	p_date          IN      DATE,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
) IS
BEGIN
	IF (NVL(p_date,FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE) THEN
	    FND_MESSAGE.SET_NAME('CSI','CSI_API_REQD_PARAM_MISSING');
    	    FND_MESSAGE.SET_TOKEN('API_NAME',p_api_name);
	    FND_MESSAGE.SET_TOKEN('MISSING_PARAM',p_param_name);
	    FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
	END IF;
END Check_Reqd_Param_date;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Party_Rel_Comb_Exists                  */
/* Description : Check if the Party relationship combination */
/*                     exists already                        */
/*-----------------------------------------------------------*/

FUNCTION Is_Party_Rel_Comb_Exists
(
    p_instance_id         IN      NUMBER      ,
    p_party_source_table  IN      VARCHAR2    ,
    p_party_id            IN      NUMBER      ,
    p_relationship_type   IN      VARCHAR2    ,
    p_contact_flag        IN      VARCHAR2    ,
    p_contact_ip_id       IN      NUMBER      ,
    p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

 l_inst_party_id NUMBER;
 l_return_value  BOOLEAN := TRUE;

BEGIN
	SELECT instance_party_id
    INTO l_inst_party_id
	FROM csi_i_parties
	WHERE instance_id        = p_instance_id
      and party_source_table     = p_party_source_table
      and party_id               = p_party_id
      and relationship_type_code = p_relationship_type
      and contact_flag           = p_contact_flag
      and NVL(contact_ip_id,fnd_api.g_miss_num) = nvl(p_contact_ip_id,fnd_api.g_miss_num)
      and ((active_end_date is null) OR (active_end_date >= sysdate));

    IF ( p_stack_err_msg = TRUE ) THEN
	  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_REL_COMB');
	  FND_MESSAGE.SET_TOKEN('PARTY_REL_COMB',to_char(p_instance_id) ||','||p_party_source_table||','||to_char(p_party_id)||','||p_relationship_type||','||to_char(p_contact_ip_id));
	  FND_MSG_PUB.Add;
    END IF;
  RETURN l_return_value;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
  WHEN TOO_MANY_ROWS THEN
   l_return_value  := TRUE;
   IF ( p_stack_err_msg = TRUE ) THEN
	  FND_MESSAGE.SET_NAME('CSI','CSI_API_MANY_PTY_REL_COM_EXIST');
	  FND_MESSAGE.SET_TOKEN('PARTY_REL_COMB',to_char(p_instance_id) ||','||p_party_source_table||','|| to_char(p_party_id)||','||p_relationship_type||','|| to_char(p_contact_ip_id));
	  FND_MSG_PUB.Add;
    END IF;
    RETURN l_return_value;
END Is_Party_Rel_Comb_Exists;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Inst_PartyID_exists                    */
/* Description : Check if the Instance Party Id exists       */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_PartyID_exists
( p_Instance_party_id     IN      NUMBER,
  p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

  l_dummy         VARCHAR2(1);
  l_return_value  BOOLEAN := TRUE;
BEGIN
    SELECT 'x'
      INTO l_dummy
     FROM csi_i_parties
    WHERE instance_party_id = p_Instance_party_id;
    IF ( p_stack_err_msg = TRUE ) THEN
	  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
	  FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_instance_party_id);
	  FND_MSG_PUB.Add;
    END IF;
    RETURN l_return_value;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
END Is_Inst_PartyID_exists;

/*-----------------------------------------------------------*/
/* Procedure name: Is_InstanceID_Valid                       */
/* Description : Check if the Instance Id exists             */
/*-----------------------------------------------------------*/

FUNCTION Is_InstanceID_Valid
(	p_instance_id           IN      NUMBER,
	p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;

   CURSOR c1 IS
	SELECT 'x'
	FROM csi_item_instances
	WHERE instance_id = p_instance_id
      --and ((active_end_date is null) OR (active_end_date >= sysdate)); commented Bug 8768694
      and ((active_end_date is null) OR (To_Date(active_end_date,'DD-MM-YY HH24:MI') >= to_date(SYSDATE,'DD-MM-YY HH24:MI')));

BEGIN
	OPEN c1;
	FETCH c1 INTO l_dummy;
	IF c1%NOTFOUND THEN
		l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INSTANCE_ID');
		   FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
		   FND_MSG_PUB.Add;
		END IF;
	END IF;
	CLOSE c1;
	RETURN l_return_value;

END Is_InstanceID_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Pty_Source_tab_Valid                   */
/* Description : Check if the Party Source Table is          */
/*              defined in CSI_LOOKUPS                       */
/*-----------------------------------------------------------*/

FUNCTION Is_Pty_Source_tab_Valid
(
    p_party_source_table    IN VARCHAR2,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

	l_dummy                 VARCHAR2(1);
	l_return_value          BOOLEAN := TRUE;
        l_pty_lookup_type       VARCHAR2(30) := 'CSI_PARTY_SOURCE_TABLE';

	CURSOR c1 IS
  	SELECT 'x'
	FROM csi_lookups
	WHERE lookup_code = UPPER(p_party_source_table)
        AND lookup_type   = l_pty_lookup_type;
BEGIN
	OPEN c1;
	FETCH c1 INTO l_dummy;
	IF c1%NOTFOUND THEN
		l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_SOURCE');
		   FND_MESSAGE.SET_TOKEN('PARTY_SOURCE_TABLE',p_party_source_table);
		   FND_MSG_PUB.Add;
		END IF;
	END IF;
	CLOSE c1;
	RETURN l_return_value;

END Is_Pty_Source_tab_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Party_Valid                            */
/* Description : Check if the Party Id exists in hz_parties  */
/*    po_vendors , employee  depending on party_source_table */
/*         value                                             */
/*-----------------------------------------------------------*/

FUNCTION Is_Party_Valid
(	p_party_source_table    IN      VARCHAR2,
        p_party_id              IN      NUMBER ,
	p_contact_flag          IN      VARCHAR2,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

	l_dummy         VARCHAR2(1);
	l_return_value BOOLEAN := TRUE;
BEGIN
    IF p_party_source_table     = 'HZ_PARTIES'   THEN

        SELECT 'x'
        INTO l_dummy
	FROM hz_parties
	WHERE party_id = p_party_id;

    ELSIF p_party_source_table  = 'PO_VENDORS' THEN
       IF p_contact_flag = 'Y' THEN
          SELECT 'x'
	  INTO l_dummy
	  FROM po_vendor_contacts
	  WHERE vendor_contact_id = p_party_id;
       ELSE
          SELECT 'x'
	    INTO l_dummy
	    FROM po_vendors
	    WHERE vendor_id = p_party_id
            AND ((end_date_active is null) OR (end_date_active >= sysdate));
       END IF;

    ELSIF p_party_source_table  = 'EMPLOYEE' THEN
        SELECT 'x'
        INTO l_dummy
	FROM per_all_people_f
	WHERE person_id = p_party_id
        AND ((effective_end_date is null) OR (effective_end_date >= sysdate))
        AND rownum < 2;

    ELSIF p_party_source_table  = 'TEAM' THEN
        SELECT 'x'
        INTO l_dummy
	FROM jtf_rs_teams_vl
	WHERE team_id = p_party_id
        AND ((end_date_active is null) OR (end_date_active >= sysdate));

    ELSIF p_party_source_table  = 'GROUP' THEN
        SELECT 'x'
        INTO l_dummy
	FROM jtf_rs_groups_vl
	WHERE group_id = p_party_id
        AND ((end_date_active is null) OR (end_date_active >= sysdate));
    ELSE
        l_return_value := FALSE;
	IF ( p_stack_err_msg = TRUE ) THEN
		FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_SOURCE');
		FND_MESSAGE.SET_TOKEN('PARTY_SOURCE_TABLE',p_party_source_table );
		FND_MSG_PUB.Add;
	END IF;
    END IF;
    RETURN l_return_value;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
	l_return_value := FALSE;
	IF ( p_stack_err_msg = TRUE ) THEN
		FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_ID');
		FND_MESSAGE.SET_TOKEN('PARTY_ID',p_party_id);
		FND_MSG_PUB.Add;
	END IF;
	RETURN l_return_value;
END  Is_Party_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Party_Rel_type_code_Valid              */
/* Description : Check if the Party relationship type code   */
/*         exists in CSI_LOOKUPS table                       */
/*-----------------------------------------------------------*/

FUNCTION  Is_Pty_Rel_type_Valid
(      p_party_rel_type_code   IN      VARCHAR2,
       p_contact_flag          IN      VARCHAR2,
       p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_dummy                 VARCHAR2(1);
	l_return_value          BOOLEAN := TRUE;


BEGIN
   IF p_contact_flag = 'P' THEN
    select 'x'
      into l_dummy
     from csi_ipa_relation_types
    where ipa_relation_type_code = UPPER(p_party_rel_type_code)
      and party_use_flag = 'Y';

  ELSIF p_contact_flag = 'A' THEN
    select 'x'
      into l_dummy
     from csi_ipa_relation_types
    where ipa_relation_type_code = UPPER(p_party_rel_type_code)
      and account_use_flag = 'Y';

  ELSIF p_contact_flag = 'C' THEN
    select 'x'
     into l_dummy
     from csi_ipa_relation_types
    where ipa_relation_type_code = UPPER(p_party_rel_type_code)
      and contact_use_flag = 'Y';
  END IF;
 RETURN l_return_value;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
	l_return_value := FALSE;
	IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_PARTY_TYPE_CODE');
		   FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE_CODE',p_party_rel_type_code);
		   FND_MSG_PUB.Add;
	END IF;
 RETURN l_return_value;
END Is_Pty_Rel_type_Valid ;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Contact_Valid                          */
/* Description : Check if it is defined as a contact for     */
/*         party_id in hz_party_relationships                */
/*-----------------------------------------------------------*/

FUNCTION Is_Contact_Valid
( p_contact_party_id          IN      NUMBER,
  p_contact_source_table      IN      VARCHAR2,
  p_ip_contact_id             IN      NUMBER,
  p_stack_err_msg             IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

 l_party_id               NUMBER ;
 l_party_source_table     VARCHAR2(30) ;
 l_dummy                  VARCHAR2(1);
 l_return_value           BOOLEAN := TRUE;
 l_org_id                 NUMBER;

 CURSOR C1( i_inst_party_id IN NUMBER)IS
 SELECT cip.party_id,
        cip.party_source_table
 FROM   csi_i_parties cip,
        csi_item_instances cii
 WHERE  cip.instance_party_id = i_inst_party_id
 AND    cip.instance_id = cii.instance_id
 AND   ((cip.active_end_date IS NULL) OR (cip.active_end_date >= SYSDATE));

-- The following code has been modified by sguthiva for bug 2428675
   CURSOR C2 (i_contact_id IN NUMBER ,
              i_party_id   IN NUMBER ) IS
   SELECT 'x'
   FROM     hz_relationships r
   ,        hz_org_contacts c
   ,        ar_lookups l
   WHERE   (r.object_id = i_party_id
            OR
            r.object_id IN (SELECT DISTINCT ha.party_id
                            FROM   hz_cust_accounts ha
                                  ,hz_cust_acct_relate_all rel
                                  ,hz_cust_accounts hz
                            WHERE  ha.cust_account_id=rel.related_cust_account_id
                            AND    rel.cust_account_id=hz.cust_account_id
                            AND    rel.status='A'
                            AND    hz.party_id=i_party_id)
             )
   AND      r.relationship_id = c.party_relationship_id
   AND      r.subject_id = i_contact_id
   AND      r.directional_flag = 'F'
   AND      r.relationship_code = l.lookup_code
   AND      l.lookup_type = 'PARTY_RELATIONS_TYPE';
-- End of modification by sguthiva for bug 2428675
BEGIN

    -- Fetch contact id and its source table
    OPEN C1(p_ip_contact_id);
    FETCH C1 INTO l_party_id, l_party_source_table;
    IF C1%NOTFOUND THEN
       l_return_value  := FALSE;
       IF ( p_stack_err_msg = TRUE ) THEN
	 FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_CONTACT_INFO');
	 FND_MESSAGE.SET_TOKEN('CONTACT_PARTY_ID',p_contact_party_id);
	 FND_MESSAGE.SET_TOKEN('CONTACT_SOURCE_TABLE',p_contact_source_table);
         FND_MSG_PUB.Add;
       END IF;
    CLOSE C1;
    RETURN l_return_value;
    END IF;

    IF (p_contact_source_table = 'HZ_PARTIES')
       AND (l_party_source_table = 'HZ_PARTIES') THEN

       OPEN C2(p_contact_party_id,l_party_id);
       FETCH C2 INTO l_dummy;
       IF C2%NOTFOUND THEN
	    l_return_value  := FALSE;
            IF ( p_stack_err_msg = TRUE ) THEN
	      FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_CONTACT_INFO');
	      FND_MESSAGE.SET_TOKEN('CONTACT_PARTY_ID',p_contact_party_id);
	      FND_MESSAGE.SET_TOKEN('CONTACT_SOURCE_TABLE',p_contact_source_table);
              FND_MSG_PUB.Add;
            END IF;
	CLOSE C2;
	END IF;
    ELSE
        l_return_value  := TRUE;
    END IF;

    RETURN l_return_value;
END Is_Contact_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_StartDate_Valid                        */
/* Description : Check if party relationship active start    */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
(   p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_instance_start_date         DATE;
	l_instance_end_date           DATE;
	l_return_value                BOOLEAN := TRUE;

    CURSOR c1 IS
	SELECT active_start_date,
               active_end_date
	FROM  csi_item_instances
	WHERE instance_id = p_instance_id
        and ((active_end_date is null) OR (To_Date(active_end_date,'DD-MM-YY HH24:MI') >= to_date(SYSDATE,'DD-MM-YY HH24:MI')));
BEGIN
   IF ((p_end_date is NOT NULL) AND (p_end_date <> FND_API.G_MISS_DATE))THEN
      IF To_Date(p_start_date,'DD-MM-YY HH24:MI') > To_Date(p_end_date,'DD-MM-YY HH24:MI') THEN
           l_return_value  := FALSE;
     	   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_START_DATE');
	       FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',p_start_date);
	       FND_MSG_PUB.Add;
           RETURN l_return_value;
      END IF;
   END IF;

	OPEN c1;
	FETCH c1 INTO l_instance_start_date,l_instance_end_date;
	IF c1%NOTFOUND THEN
		l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INST_STARTDATE_NOT_EXT');
       	   FND_MSG_PUB.Add;
		END IF;
    CLOSE c1;
    RETURN l_return_value;
    END IF;

    IF ((p_start_date < l_instance_start_date)
           OR  ((l_instance_end_date IS NOT NULL) AND (p_start_date > l_instance_end_date))
           OR (p_start_date > SYSDATE)) THEN
        l_return_value  := FALSE;
	IF ( p_stack_err_msg = TRUE ) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_START_DATE');
          FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',p_start_date);
	  FND_MSG_PUB.Add;
	END IF;
    END IF;
  RETURN l_return_value;
END Is_StartDate_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_EndDate_Valid                          */
/* Description : Check if party relationship active end      */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

/*
FUNCTION Is_EndDate_Valid
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN NUMBER,
	p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_instance_end_date         DATE;
	l_instance_start_date         DATE;
	l_return_value  BOOLEAN := TRUE;

   CURSOR c1 IS
	SELECT active_end_date,
               active_start_date
	FROM csi_item_instances
	WHERE instance_id = p_instance_id
        and ((active_end_date is null) OR (to_date(active_end_date,'DD-MM-YY HH24:MI') >= to_date(sysdate,'DD-MM-YY HH24:MI')));
BEGIN
  IF p_end_date is NOT NULL THEN
      IF to_date(p_end_date,'DD-MM-YY HH24:MI') < to_date(sysdate,'DD-MM-YY HH24:MI') THEN
           l_return_value  := FALSE;
    	   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_END_DATE');
	       FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	       FND_MSG_PUB.Add;
           RETURN l_return_value;
      END IF;
  END IF;

	OPEN c1;
	FETCH c1 INTO l_instance_end_date ,l_instance_start_date;

        IF l_instance_end_date is NOT NULL THEN
          IF ((p_end_date > l_instance_end_date) OR
               (p_end_date < l_instance_start_date))THEN
            l_return_value  := FALSE;
    		IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_END_DATE');
	          FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	          FND_MSG_PUB.Add;
         	END IF;
          END IF;
        END IF;
	CLOSE c1;
 RETURN l_return_value;

END Is_EndDate_Valid;
*/

/*-----------------------------------------------------------*/
/* Procedure name: Is_EndDate_Valid                          */
/* Description : Check if party relationship active end      */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_EndDate_Valid
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN NUMBER,
    p_instance_party_id     IN NUMBER,
    p_txn_id                IN NUMBER,
    p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_instance_end_date         DATE;
	l_instance_start_date         DATE;
	l_return_value  BOOLEAN := TRUE;

   CURSOR c1 IS
	SELECT active_end_date,
               active_start_date
	FROM csi_item_instances
	WHERE instance_id = p_instance_id
        and ((active_end_date is null) OR (to_date(active_end_date,'DD-MM-YY HH24:MI') >= to_date(sysdate,'DD-MM-YY HH24:MI')));
BEGIN

IF ((p_instance_party_id is null) or (p_instance_party_id = fnd_api.g_miss_num)) then

  IF ((p_end_date is NOT NULL) and (p_end_date <> fnd_api.g_miss_date)) THEN
      IF to_date(p_end_date,'DD-MM-YY HH24:MI') < to_date(sysdate,'DD-MM-YY HH24:MI') THEN
           l_return_value  := FALSE;
    	   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_END_DATE');
	       FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	       FND_MSG_PUB.Add;
           RETURN l_return_value;
      END IF;
  END IF;

ELSE
  IF to_date(p_end_date,'DD-MM-YY HH24:MI') < to_date(sysdate,'DD-MM-YY HH24:MI') THEN

    IF NOT (GET_PARTIES
     (
      p_start_date           =>  p_start_date,
      p_end_date             =>  p_end_date,
	 p_instance_party_id    =>  p_instance_party_id,
	 p_txn_id               =>  p_txn_id
     )) THEN
        l_return_value := FALSE;
        RETURN l_return_value;
    END IF;
  END IF;

  IF ((p_end_date is NOT NULL) and (p_end_date <> fnd_api.g_miss_date)) THEN
  OPEN c1;
	FETCH c1 INTO l_instance_end_date ,l_instance_start_date;

        IF l_instance_end_date is NOT NULL THEN
          IF ((p_end_date > l_instance_end_date) OR
               (p_end_date < l_instance_start_date))THEN
            l_return_value  := FALSE;
    		IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_END_DATE');
	          FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	          FND_MSG_PUB.Add;
         	END IF;
          END IF;
        END IF;
	CLOSE c1;
   END IF;
  END IF;
 RETURN l_return_value;

END Is_EndDate_Valid;

--Added by rtalluri for end_date validation 02/19/02
FUNCTION get_parties
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_party_id     IN   NUMBER,
    p_txn_id                IN   NUMBER
)
RETURN BOOLEAN IS

    l_transaction_date date;
    l_party_temp number;
    l_contact_temp number;
    l_account_temp number;
 	l_return_value  BOOLEAN := TRUE;

    CURSOR C1 is
      SELECT instance_party_id
      FROM   csi_i_parties
      WHERE  contact_ip_id = p_instance_party_id
      AND    ((active_end_date is null) or (active_end_date > sysdate));

    CURSOR C2 is
      SELECT ip_account_id
      FROM   csi_ip_accounts
      WHERE  instance_party_id = p_instance_party_id
      AND    ((active_end_date is null) or (active_end_date > sysdate));

BEGIN

      SELECT MAX(t.source_transaction_date) -- Changed from Transaction_date to Source_transaction_date
      INTO   l_transaction_date
      FROM   csi_i_parties_h s,
             csi_transactions t
      WHERE  s.instance_party_id=p_instance_party_id
      AND    s.transaction_id=t.transaction_id
	 AND    t.transaction_id <>nvl(p_txn_id, -99999);

        IF l_transaction_date > p_end_date
         THEN
          fnd_message.set_name('CSI','CSI_HAS_TXNS');
          fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
          fnd_msg_pub.add;
          l_return_value := FALSE;
          RETURN l_return_value;
        END IF;

       OPEN C1;
        FETCH C1 into l_contact_temp;
        IF C1%FOUND then
            SELECT MAX(t.source_transaction_date) -- Changed from Transaction_date to Source_transaction_date
            INTO   l_transaction_date
            FROM   csi_i_parties_h s,
                   csi_transactions t
            WHERE  s.instance_party_id=l_contact_temp
            AND    s.transaction_id=t.transaction_id
	       AND    t.transaction_id <> nvl(p_txn_id, -99999);

            IF l_transaction_date > p_end_date
            THEN
             fnd_message.set_name('CSI','CSI_HAS_TXNS');
             fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
             fnd_msg_pub.add;
             l_return_value := FALSE;
             RETURN l_return_value;
            END IF;
        END IF;
       CLOSE C1;

       OPEN C2;
       FETCH C2 into l_account_temp;
       IF C2%FOUND then
            SELECT MAX(t.source_transaction_date) -- Changed from Transaction_date to Source_transaction_date
            INTO   l_transaction_date
            FROM   csi_ip_accounts_h s,
                   csi_transactions t
            WHERE  s.ip_account_id =l_account_temp
            AND    s.transaction_id=t.transaction_id
	       AND    t.transaction_id <> nvl(p_txn_id, -99999);

            IF l_transaction_date > p_end_date
            THEN
             fnd_message.set_name('CSI','CSI_HAS_TXNS');
             fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
             fnd_msg_pub.add;
             l_return_value := FALSE;
             RETURN l_return_value;
            END IF;
       END IF;
      CLOSE C2;
RETURN l_return_value;
END get_parties;
--End of addition


/*-----------------------------------------------------------*/
/* Procedure name: Is_Inst_Owner_exists                      */
/* Description : Check if owner exists for instance_id       */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_Owner_exists
( p_Instance_id   IN      NUMBER,
  p_instance_party_id IN NUMBER,
  p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

 l_dummy         VARCHAR(1);
 l_return_value  BOOLEAN := TRUE;
 l_inst_party_id NUMBER;

   CURSOR C1 IS
    SELECT 'x'
    FROM csi_i_parties
   WHERE instance_id = p_Instance_id
   AND   instance_party_id <> l_inst_party_id  -- Ignore the current instance_party_id
    AND  relationship_type_code = 'OWNER'
    and ((active_end_date is null) OR (active_end_date >= sysdate));
BEGIN
   IF p_instance_party_id  IS NULL OR
      p_instance_party_id  = FND_API.G_MISS_NUM THEN
      l_inst_party_id := -99999;
   ELSE
      l_inst_party_id := p_instance_party_id;
   END IF;
    OPEN C1;
	FETCH C1 INTO l_dummy;
    IF C1%FOUND THEN
       IF ( p_stack_err_msg = TRUE ) THEN
     	  FND_MESSAGE.SET_NAME('CSI','CSI_API_OWNER_ALREADY_EXISTS');
    	  FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
	      FND_MSG_PUB.Add;
      END IF;
    ELSE
       l_return_value  := FALSE;
    END IF;
    CLOSE C1;
  RETURN l_return_value;
 EXCEPTION
  WHEN OTHERS THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
END Is_Inst_Owner_exists;

/*-----------------------------------------------------------*/
/* Procedure name: gen_inst_party_id                         */
/* Description : Generate instance_party_id from the sequence*/
/*-----------------------------------------------------------*/

FUNCTION gen_inst_party_id
  RETURN NUMBER IS

  l_inst_party_id NUMBER;

BEGIN
    SELECT CSI_I_PARTIES_S.nextval
     INTO l_inst_party_id
     FROM sys.dual;
  RETURN l_inst_party_id;
END gen_inst_party_id;

/*-----------------------------------------------------------*/
/* Procedure name: gen_inst_party_hist_id                    */
/* Description : Generate instance_party_history_id          */
/*               from the sequence                           */
/*-----------------------------------------------------------*/

FUNCTION gen_inst_party_hist_id
  RETURN NUMBER IS
  l_inst_party_his_id NUMBER;
BEGIN
    SELECT CSI_I_PARTIES_H_S.nextval
      INTO l_inst_party_his_id
      FROM sys.dual;
 RETURN l_inst_party_his_id ;
END gen_inst_party_hist_id;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Instance_creation_complete             */
/* Description : Check if the instance creation is           */
/*               complete                                    */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_creation_complete
(	p_instance_id           IN      NUMBER,
	p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN IS

	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
    SELECT 'x'
    INTO l_dummy
    FROM csi_item_instances
	WHERE instance_id = p_Instance_id
      AND ((active_end_date is null) OR (to_date(active_end_date,'DD-MM-YY HH24:MI') >= to_date(sysdate,'DD-MM-YY HH24:MI')))
      AND creation_complete_flag = 'Y';
	RETURN l_return_value;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  	l_return_value  := FALSE;
	RETURN l_return_value;
END Is_Inst_creation_complete;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Pty_Acct_Comb_Exists                   */
/* Description : Check if the party account combination      */
/*               exists in csi_ip_accounts                   */
/*-----------------------------------------------------------*/

FUNCTION Is_Pty_Acct_Comb_Exists
(
   p_instance_party_id    IN   NUMBER ,
   p_party_account_id     IN   NUMBER ,
   p_relationship_type    IN   VARCHAR2,
   p_stack_err_msg        IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

 l_dummy         VARCHAR2(1);
 l_return_value  BOOLEAN := TRUE;

BEGIN

   SELECT 'x'
    INTO  l_dummy
    FROM  csi_ip_accounts
   WHERE  instance_party_id      = p_instance_party_id
     and  party_account_id       = p_party_account_id
     and  relationship_type_code = p_relationship_type
     and ((active_end_date is null) OR (to_date(active_end_date,'DD-MM-YY HH24:MI') >= to_date(sysdate,'DD-MM-YY HH24:MI')));
     IF ( p_stack_err_msg = TRUE ) THEN
   	    FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PARTY_ACCT_COM');
	    FND_MESSAGE.SET_TOKEN('ACCT_COMBINATION',p_instance_party_id ||', '
                      ||p_party_account_id ||', '||p_relationship_type);
	    FND_MSG_PUB.Add;
     END IF;
   RETURN l_return_value;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
    l_return_value := FALSE;
   RETURN l_return_value;
END Is_Pty_Acct_Comb_Exists;

/*-----------------------------------------------------------*/
/* Procedure name: Is_IP_account_Exists                      */
/* Description : Check if the IP_account_id                  */
/*               exists in csi_ip_accounts                   */
/*-----------------------------------------------------------*/

FUNCTION Is_IP_account_Exists
(	p_ip_account_id       IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS
	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
	FROM csi_ip_accounts
	WHERE ip_account_id = p_ip_account_id
      and ((active_end_date is null) OR (to_date(active_end_date,'DD-MM-YY HH24:MI') >= to_date(sysdate,'DD-MM-YY HH24:MI')));
	IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_IP_ACCOUNT_ID');
		   FND_MESSAGE.SET_TOKEN('IP_ACCOUNT_ID',p_ip_account_id);
		   FND_MSG_PUB.Add;
	END IF;
	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
	RETURN l_return_value;
END Is_IP_account_Exists ;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Inst_partyID_Expired                   */
/* Description : Check if the instance_party_id              */
/*               is expired                                  */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_partyID_Expired
(
 p_Instance_party_id     IN      NUMBER,
 p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

 l_inst_party_id NUMBER;
 l_return_value  BOOLEAN := TRUE;

BEGIN
    SELECT instance_party_id
    INTO l_inst_party_id
    FROM csi_i_parties
    WHERE instance_party_id = p_Instance_party_id;
    RETURN l_return_value;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
END Is_Inst_partyID_Expired;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Inst_partyID_Valid                     */
/* Description : Check if the instance_party_id              */
/*               exists in csi_i_parties                     */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_partyID_Valid
(
 p_Instance_party_id     IN      NUMBER,
 p_txn_type_id           IN      NUMBER,   -- Added for bug 3550541
 p_mode                  IN      VARCHAR2, -- Added for bug 3550541
 p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE

) RETURN BOOLEAN IS

 l_instance_id NUMBER;
 l_return_value  BOOLEAN := TRUE;

BEGIN
    SELECT instance_id
    INTO l_instance_id
    FROM csi_i_parties
    WHERE instance_party_id = p_Instance_party_id
    AND ((active_end_date is null) OR (active_end_date >= sysdate));
    --
    -- srramakr Instance ID validation added for bug # 2477417.
    IF NOT(CSI_Instance_parties_vld_pvt.Is_InstanceID_Valid(l_instance_id)) THEN
       l_return_value  := FALSE;
    END IF;
    RETURN l_return_value;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
  -- Added for bug 3550541
    IF p_txn_type_id=7 AND
       p_mode='U'
    THEN
    -- Check for the existence of instance_party_id in the database.
     BEGIN
      SELECT instance_id
      INTO l_instance_id
      FROM csi_i_parties
      WHERE instance_party_id = p_Instance_party_id;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
       l_return_value  := FALSE;
       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
       FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_INSTANCE_PARTY_ID);
       FND_MSG_PUB.Add;
     END;
   -- End addition for bug 3550541
    ELSE
    l_return_value  := FALSE;
      IF p_stack_err_msg = TRUE THEN
       FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
       FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_INSTANCE_PARTY_ID);
       FND_MSG_PUB.Add;
      END IF;
    END IF;
  RETURN l_return_value;
END Is_Inst_partyID_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Pty_accountID_Valid                    */
/* Description : Check if the party account_id               */
/*               exists in hz_cust_accounts                  */
/*-----------------------------------------------------------*/

FUNCTION Is_Pty_accountID_Valid
(   p_party_account_id       IN      NUMBER,
	p_instance_party_id      IN      NUMBER,
    p_relationship_type_code IN      VARCHAR2,
    p_txn_type_id            IN      NUMBER,   -- Added for bug 3550541
    p_mode                   IN      VARCHAR2, -- Added for bug 3550541
	p_stack_err_msg          IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS
	l_dummy                  VARCHAR2(1);
	l_return_value           BOOLEAN := TRUE;
    l_party_id               NUMBER;
    l_party_source_table     VARCHAR2(30);

   CURSOR C1(i_party_account_id NUMBER) IS
	SELECT 'x'
	  FROM hz_cust_accounts
	 WHERE cust_account_id = i_party_account_id;

   CURSOR C2(i_party_account_id NUMBER,
             i_party_id         NUMBER) IS
      SELECT 'x'
	FROM  hz_cust_accounts hzca,
              hz_parties  hzp
       WHERE  hzca.cust_account_id = i_party_account_id
         AND  hzca.party_id = i_party_id
         AND  hzca.party_id = hzp.party_id;

   CURSOR C3(i_inst_party_id NUMBER) IS
     SELECT party_id,
            party_source_table
      FROM  csi_i_parties
     WHERE  instance_party_id = i_inst_party_id
       AND ((active_end_date is null) OR (active_end_date >= sysdate));


BEGIN
    -- Fetch partty  or contact id and its source table
    OPEN C3(p_instance_party_id);
    FETCH C3 INTO l_party_id, l_party_source_table;
    IF C3%NOTFOUND THEN
    -- Added for bug 3550541
     IF p_txn_type_id = 7 AND
        p_mode='U'
     THEN
      BEGIN
      -- Check for the existence of instance_party_id in the database.
        SELECT party_id,
               party_source_table
        INTO   l_party_id,
               l_party_source_table
        FROM   csi_i_parties
        WHERE  instance_party_id = p_instance_party_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_return_value  := FALSE;
          FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
	      FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_instance_party_id);
          FND_MSG_PUB.Add;
      -- Errored, No need to proceed further
          RETURN l_return_value;
      END;
      -- End addition for bug 3550541
     ELSE
       l_return_value  := FALSE;
       IF ( p_stack_err_msg = TRUE ) THEN
	     FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
	     FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_instance_party_id);
         FND_MSG_PUB.Add;
       END IF;
      CLOSE C3;
      -- Errored, No need to proceed further
      RETURN l_return_value;
     END IF;
    END IF;

    IF (--(p_relationship_type_code = 'OWNER') AND -- Need to check for all rel.
        (l_party_source_table = 'HZ_PARTIES'))
    THEN
      OPEN C2(p_party_account_id, l_party_id);
      FETCH C2 INTO l_dummy;
	   IF c2%NOTFOUND
       THEN
		l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE )
        THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_PTY_ACCT_HZ_PTY');
		   FND_MESSAGE.SET_TOKEN('PARTY_ACCOUNT_ID',p_party_account_id);
	       FND_MESSAGE.SET_TOKEN('PARTY_ID',l_party_id);
		   FND_MSG_PUB.Add;
        END IF;
       END IF;
      CLOSE c2;
    ELSE
      OPEN C1(p_party_account_id);
      FETCH C1 INTO l_dummy;
       IF c1%NOTFOUND
       THEN
		l_return_value  := FALSE;
        IF ( p_stack_err_msg = TRUE )
        THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_PTY_ACCT_ID');
           FND_MESSAGE.SET_TOKEN('PARTY_ACCOUNT_ID',p_party_account_id);
           FND_MSG_PUB.Add;
        END IF;
       END IF;
      CLOSE c1;
    END IF;
     RETURN l_return_value;
END Is_pty_accountID_Valid;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Acct_Rel_type_Valid                    */
/* Description : Check if the Party account relationship     */
/*               type code exists in CSI_LOOKUPS             */
/*-----------------------------------------------------------*/

FUNCTION  Is_Acct_Rel_type_Valid
(      p_acct_rel_type_code   IN      VARCHAR2,
       p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN IS

	l_dummy                 VARCHAR2(1);
	l_return_value          BOOLEAN := TRUE;

	CURSOR c1 IS
    select 'x'
    from csi_ipa_relation_types
    where ipa_relation_type_code = UPPER(p_acct_rel_type_code)
      and account_use_flag = 'Y';

BEGIN
	OPEN c1;
	FETCH c1 INTO l_dummy;
	IF c1%NOTFOUND THEN
		l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ACCOUNT_TYPE');
		   FND_MESSAGE.SET_TOKEN('IP_RELATIONSHIP_TYPE_CODE',p_acct_rel_type_code);
		   FND_MSG_PUB.Add;
		END IF;
	END IF;
	CLOSE c1;
	RETURN l_return_value;
END Is_Acct_Rel_type_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Acct_StartDate_Valid                   */
/* Description : Check if the Account active Start date      */
/*               is valid                                    */
/*-----------------------------------------------------------*/

FUNCTION Is_Acct_StartDate_Valid
(   p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_party_id     IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_inst_party_start_date         DATE;
	l_return_value                  BOOLEAN := TRUE;

    CURSOR c1 IS
	SELECT active_start_date
	 FROM csi_i_parties
	WHERE instance_party_id = p_instance_party_id
      and ((active_end_date is null) OR (active_end_date >= sysdate));
BEGIN
   IF (p_end_date is NOT NULL) AND (p_end_date <> FND_API.G_MISS_DATE)  THEN

      -- Modified date comparision for bug 7333900, ignore difference in seconds
      IF (to_date(p_start_date,'DD-MM-YY HH24:MI') > to_date(p_end_date,'DD-MM-YY HH24:MI')) THEN
           l_return_value  := FALSE;
     	   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ACCT_START_DATE');
	       FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',p_start_date);
	       FND_MSG_PUB.Add;
           RETURN l_return_value;
      END IF;
   END IF;

	OPEN c1;
	FETCH c1 INTO l_inst_party_start_date;
	IF c1%NOTFOUND THEN
		l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
                  FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_PTY_START_DATE');
                   FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',p_start_date);
	   	   FND_MSG_PUB.Add;
		END IF;
         CLOSE c1;
         RETURN l_return_value;
	 END IF;

   -- dbms_output.put_line('p_start-date :'||to_char(p_start_date));
   -- dbms_output.put_line('l_inst_party_start_date :'||to_char(l_inst_party_start_date));

    -- Modified date comparison for bug 7333900, ignore difference in seconds
    IF (to_date(p_start_date,'DD-MM-YY HH24:MI') < to_date(l_inst_party_start_date,'DD-MM-YY HH24:MI'))
      OR (to_date(p_start_date,'DD-MM-YY HH24:MI') > to_date(SYSDATE,'DD-MM-YY HH24:MI')) THEN
        l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ACCT_START_DATE');
           FND_MESSAGE.SET_TOKEN('ACTIVE_START_DATE',p_start_date);
	   	   FND_MSG_PUB.Add;
		END IF;
    END IF;
    RETURN l_return_value;

END Is_Acct_StartDate_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Acct_EndDate_Valid                     */
/* Description : Check if the Account active End date        */
/*               is valid                                    */
/*-----------------------------------------------------------*/

/*
FUNCTION Is_Acct_EndDate_Valid
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_inst_party_id         IN   NUMBER,
	p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_instance_end_date         DATE;
	l_return_value              BOOLEAN := TRUE;

   CURSOR c1 IS
	SELECT active_end_date
	FROM csi_i_parties
	WHERE instance_party_id = p_inst_party_id
     and ((active_end_date is null) OR (active_end_date >= sysdate));
BEGIN
  IF p_end_date is NOT NULL THEN
      IF p_end_date < sysdate THEN
           l_return_value  := FALSE;
    	   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ACCT_END_DATE');
	       FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	       FND_MSG_PUB.Add;
         RETURN l_return_value;
      END IF;
  END IF;

  OPEN c1;
  FETCH c1 INTO l_instance_end_date;

  IF l_instance_end_date is NOT NULL THEN
        IF p_end_date > l_instance_end_date THEN
            l_return_value  := FALSE;
    	  IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ACCT_END_DATE');
	          FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	          FND_MSG_PUB.Add;
          END IF;
        END IF;
  END IF;
  CLOSE c1;
  RETURN l_return_value;
END Is_Acct_EndDate_Valid;

*/

/*-----------------------------------------------------------*/
/* Procedure name: Is_Acct_EndDate_Valid                     */
/* Description : Check if the Account active End date        */
/*               is valid                                    */
/*-----------------------------------------------------------*/

FUNCTION Is_Acct_EndDate_Valid
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_inst_party_id         IN   NUMBER,
    p_ip_account_id         IN   NUMBER,
    p_txn_id                IN   NUMBER,
	p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_instance_end_date         DATE;
	l_return_value              BOOLEAN := TRUE;
    l_transaction_date          DATE;

   CURSOR c1 IS
	SELECT active_end_date
	FROM csi_i_parties
	WHERE instance_party_id = p_inst_party_id
     and ((active_end_date is null) OR (active_end_date >= sysdate));
BEGIN
   IF  ((p_ip_account_id IS NULL) OR  (p_ip_account_id = FND_API.G_MISS_NUM))
   THEN
       IF ((p_end_date is NOT NULL) and (p_end_date <> fnd_api.g_miss_date))
       THEN
           IF p_end_date < sysdate
           THEN
             l_return_value  := FALSE;
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ACCT_END_DATE');
	          FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	          FND_MSG_PUB.Add;
              l_return_value := FALSE;
              RETURN l_return_value;
            END IF;
        END IF;
       RETURN l_return_value;

   ELSE

      IF p_end_date < sysdate THEN
         SELECT MAX(t.source_transaction_date) -- Changed from Transaction_date to Source_transaction_date
         INTO   l_transaction_date
         FROM   csi_ip_accounts_h s,
                csi_transactions t
         WHERE  s.ip_account_id=p_ip_account_id
         AND    s.transaction_id=t.transaction_id
	 AND    t.transaction_id <> nvl(p_txn_id, -99999);

          IF l_transaction_date > p_end_date
           THEN
            fnd_message.set_name('CSI','CSI_HAS_TXNS');
            fnd_message.set_token('END_DATE_ACTIVE',p_end_date);
            fnd_msg_pub.add;
            l_return_value := FALSE;
            RETURN l_return_value;
          END IF;
      END IF;

      IF ((p_end_date is not null) and (p_end_date <> fnd_api.g_miss_date)) then

       OPEN c1;
        FETCH c1 INTO l_instance_end_date;

         IF l_instance_end_date is NOT NULL THEN
          IF p_end_date > l_instance_end_date THEN
            l_return_value  := FALSE;
    	   IF ( p_stack_err_msg = TRUE ) THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ACCT_END_DATE');
	          FND_MESSAGE.SET_TOKEN('ACTIVE_END_DATE',p_end_date);
	          FND_MSG_PUB.Add;
           END IF;
          END IF;
         END IF;
       CLOSE c1;
      END IF;
    END IF;
  RETURN l_return_value;
END Is_Acct_EndDate_Valid;



/*-----------------------------------------------------------*/
/* Procedure name: gen_ip_account_id                         */
/* Description : Generate ip_account_id from the sequence    */
/*-----------------------------------------------------------*/

FUNCTION gen_ip_account_id
  RETURN NUMBER IS
  l_ip_account_id  NUMBER;
BEGIN

    SELECT CSI_IP_ACCOUNTS_S.nextval
     INTO l_ip_account_id
    FROM sys.dual;
   RETURN l_ip_account_id ;
END gen_ip_account_id;

/*-----------------------------------------------------------*/
/* Procedure name: gen_ip_account_hist_id                    */
/* Description : Generate ip_account_hist_id from            */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION gen_ip_account_hist_id
  RETURN NUMBER IS
  l_ip_account_hist_id  NUMBER;
BEGIN
     SELECT CSI_IP_ACCOUNTS_H_S.nextval
       INTO l_ip_account_hist_id
       FROM sys.dual;
    RETURN l_ip_account_hist_id ;
END gen_ip_account_hist_id;

/*------------------------------------------------------------*/
/* Procedure name: Is_datetimestamp_Valid                     */
/* Description : Check if datetimestamp is greater than       */
/*  start effective date but less than the end effective date */
/*------------------------------------------------------------*/

FUNCTION Is_timestamp_Valid
(
    p_datetimestamp         IN   DATE,
    p_instance_id           IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN IS

    l_instance_start_date         DATE;
    l_instance_end_date           DATE;
	l_return_value                BOOLEAN := TRUE;

  CURSOR c1 IS
	SELECT active_start_date,
           active_end_date
	FROM csi_item_instances
	WHERE instance_id = p_instance_id
        and ((active_end_date is null) OR (To_Date(active_end_date,'DD-MM-YY HH24:MI') >= To_Date(sysdate,'DD-MM-YY HH24:MI')));
BEGIN
	OPEN c1;
	FETCH c1 INTO l_instance_start_date,l_instance_end_date;
	IF c1%NOTFOUND THEN
        l_return_value := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVAL_INST_START_DATE');
           FND_MESSAGE.SET_TOKEN('ENTITY','VERSION LABEL');
       	   FND_MSG_PUB.Add;
		END IF;
    CLOSE c1;
    RETURN l_return_value;
    END IF;

    IF (( To_Date(p_datetimestamp,'DD-MM-YY HH24:MI') <  To_Date(l_instance_start_date,'DD-MM-YY HH24:MI')) AND
         ( To_Date(p_datetimestamp,'DD-MM-YY HH24:MI') > To_Date(l_instance_end_date,'DD-MM-YY HH24:MI'))) THEN
        l_return_value := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_TIMESTAMP');
       	   FND_MSG_PUB.Add;
		END IF;
    END IF;
RETURN l_return_value;

END Is_timestamp_Valid;

/*-----------------------------------------------------------*/
/* Procedure name: gen_ver_label_id                          */
/* Description : Generate version_label_id  from             */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION gen_ver_label_id
  RETURN NUMBER IS

 l_version_label_id NUMBER;

BEGIN
 SELECT CSI_I_VERSION_LABELS_S.nextval
  INTO  l_version_label_id
  FROM sys.dual;
  RETURN l_version_label_id;
END  gen_ver_label_id;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Ver_labelID_exists                     */
/* Description : Check if the version_label_id               */
/*               exists in csi_i_version_labels              */
/*-----------------------------------------------------------*/

FUNCTION Is_Ver_labelID_exists
(	p_version_label_id      IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
	FROM csi_i_version_labels
	WHERE version_label_id = p_version_label_id
     and ((active_end_date is null) OR (active_end_date >= sysdate));
	IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_VER_LABEL_ID');
		   FND_MESSAGE.SET_TOKEN('VERSION_LABEL_ID',p_version_label_id);
		   FND_MSG_PUB.Add;
	END IF;
	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
	RETURN l_return_value;
END Is_Ver_labelID_exists;

/*-----------------------------------------------------------*/
/* Procedure name: gen_ver_label_hist_id                     */
/* Description : Generate version_label_hist_id  from        */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION gen_ver_label_hist_id
  RETURN NUMBER IS
 l_version_label_hist_id NUMBER;

BEGIN
 SELECT CSI_I_VERSION_LABELS_H_S.nextval
  INTO  l_version_label_hist_id
  FROM sys.dual;

RETURN l_version_label_hist_id;

END gen_ver_label_hist_id;

/*-----------------------------------------------------------*/
/* Procedure name:   gen_inst_asset_id                       */
/* Description : Generate instance asset id   from           */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION  gen_inst_asset_id
  RETURN NUMBER IS

  l_inst_asset_id       NUMBER;

BEGIN
 SELECT CSI_I_ASSETS_S.nextval
  INTO  l_inst_asset_id
  FROM sys.dual;

RETURN l_inst_asset_id;

END  gen_inst_asset_id;

/*-----------------------------------------------------------*/
/* Procedure name:  Is_Inst_assetID_exists                   */
/* Description : Check if the instance asset id              */
/*               exists in csi_i_assets                      */
/*-----------------------------------------------------------*/

FUNCTION  Is_Inst_assetID_exists

(	p_instance_asset_id     IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN IS

	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
     FROM csi_i_assets
	WHERE instance_asset_id = p_instance_asset_id ;

	IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_INST_ASSET_ID');
		   FND_MESSAGE.SET_TOKEN('INSTANCE_ASSET_ID',p_instance_asset_id);
		   FND_MSG_PUB.Add;
	END IF;
	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
	RETURN l_return_value;
END  Is_Inst_assetID_exists;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Update_Status_Exists                   */
/* Description : Check if the update status  is              */
/*              defined in CSI_LOOKUPS                       */
/*-----------------------------------------------------------*/

FUNCTION Is_Update_Status_Exists
(
    p_update_status         IN      VARCHAR2,
    p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

	l_dummy                 VARCHAR2(1);
	l_return_value          BOOLEAN := TRUE;
        l_asset_lookup_type     VARCHAR2(30) := 'CSI_ASSET_UPDATE_STATUS';

	CURSOR c1 IS
	SELECT 'x'
	FROM CSI_LOOKUPS
	WHERE  lookup_code    = UPPER(p_update_status)
        AND  lookup_type    = l_asset_lookup_type;
BEGIN
	OPEN c1;
	FETCH c1 INTO l_dummy;
	IF c1%NOTFOUND THEN
		l_return_value  := FALSE;
		IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_UPDATE_STATUS');
		   FND_MESSAGE.SET_TOKEN('UPDATE_STATUS',p_update_status);
		   FND_MSG_PUB.Add;
		END IF;
	END IF;
	CLOSE c1;
	RETURN l_return_value;

END Is_Update_Status_Exists;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Quantity_Valid                         */
/* Description : Check if the asset quantity > 0             */
/*-----------------------------------------------------------*/

FUNCTION Is_Quantity_Valid
(
    p_asset_quantity        IN      NUMBER,
    p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN IS

   l_return_status    BOOLEAN := TRUE;
BEGIN
	IF (NVL(p_asset_quantity,-1) <= 0 ) THEN
        l_return_status := FALSE;
      	FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_ASSET_QTY');
		FND_MESSAGE.SET_TOKEN('QUANTITY',p_asset_quantity);
		FND_MSG_PUB.Add;
	END IF;

 RETURN l_return_status;

END Is_Quantity_Valid;


/*-----------------------------------------------------------*/
/* Procedure name:   gen_inst_asset_hist_id                  */
/* Description : Generate instance asset id   from           */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION  gen_inst_asset_hist_id
  RETURN NUMBER IS

 l_inst_asset_hist_id       NUMBER;

BEGIN
  SELECT CSI_I_ASSETS_H_S.nextval
  INTO  l_inst_asset_hist_id
  FROM sys.dual;
 RETURN l_inst_asset_hist_id;
END gen_inst_asset_hist_id;

/*-----------------------------------------------------------*/
/* Procedure name:  Is_Asset_Comb_Valid                      */
/* Description : Check if the instance asset id and location */
/*               id exists in fa_books                       */
/*-----------------------------------------------------------*/

FUNCTION  Is_Asset_Comb_Valid
(	p_asset_id        IN      NUMBER,
    p_book_type_code  IN      VARCHAR2,
    p_stack_err_msg   IN      BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN IS
	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
     FROM fa_books
	WHERE asset_id       = p_asset_id
      and book_type_code = p_book_type_code;

	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ASSET_COMB');
		   FND_MESSAGE.SET_TOKEN('ASSET_COMBINATION',p_asset_id||'-'||p_book_type_code);
		   FND_MSG_PUB.Add;
	END IF;
 RETURN l_return_value;
END Is_Asset_Comb_Valid;


/*-----------------------------------------------------------*/
/* Procedure name:  Is_Asset_Location_Valid                  */
/* Description : Check if the instance location id           */
/*                exists in csi_a_locations                  */
/*-----------------------------------------------------------*/

FUNCTION  Is_Asset_Location_Valid
(   p_location_id     IN      NUMBER,
    p_stack_err_msg   IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS
	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
     FROM csi_a_locations
	WHERE location_id       = p_location_id
      and ((active_end_date is null) OR (active_end_date >= sysdate));

	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    IF ( p_stack_err_msg = TRUE ) THEN
		   FND_MESSAGE.SET_NAME('CSI','CSI_API_INV_ASSET_LOCATION');
		   FND_MESSAGE.SET_TOKEN('ASSET_LOCATION_ID',p_location_id);
		   FND_MSG_PUB.Add;
	END IF;
 RETURN l_return_value;
END Is_Asset_Location_Valid;


/*-----------------------------------------------------------*/
/* Procedure name: Is_IP_account_expired                     */
/* Description : Check if the IP_account_id                  */
/*               is expired                                  */
/*-----------------------------------------------------------*/

FUNCTION Is_IP_account_expired
(	p_ip_account_id       IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS
	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
	FROM csi_ip_accounts
	WHERE ip_account_id = p_ip_account_id;
	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
END Is_IP_account_expired ;

/*-----------------------------------------------------------*/
/* Procedure name: Is_IP_account_Valid                       */
/* Description : Check if the IP_account_id                  */
/*               exists in csi_ip_accounts                   */
/*-----------------------------------------------------------*/

FUNCTION Is_IP_account_Valid
(	p_ip_account_id       IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS
	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
     INTO l_dummy
	FROM csi_ip_accounts
	WHERE ip_account_id = p_ip_account_id
      and ((active_end_date is null) OR (active_end_date >= sysdate));
	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
END Is_IP_account_Valid ;

/*-----------------------------------------------------------*/
/* Procedure name: Is_bill_to_add_valid                      */
/* Description : Check if the Bill to address                */
/*               exists in hz_cust_site_uses                 */
/*-----------------------------------------------------------*/

FUNCTION Is_bill_to_add_valid
(	p_bill_to_add_id      IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS
	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
        INTO l_dummy
	FROM hz_cust_site_uses_all
	WHERE site_use_id = p_bill_to_add_id
        AND site_use_code = 'BILL_TO';
      -- and ((active_end_date is null) OR (active_end_date >= sysdate));
	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    IF ( p_stack_err_msg = TRUE ) THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_BILL_TO_ADD_ID');
	 FND_MESSAGE.SET_TOKEN('BILL_TO_ADD_ID',p_bill_to_add_id );
	 FND_MSG_PUB.Add;
    END IF;
    RETURN l_return_value;

END Is_bill_to_add_valid;

/*-----------------------------------------------------------*/
/* Procedure name: Is_ship_to_add_valid                      */
/* Description : Check if the Ship to address                */
/*               exists in hz_cust_site_uses                 */
/*-----------------------------------------------------------*/

FUNCTION Is_ship_to_add_valid
(	p_ship_to_add_id      IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS
	l_dummy         VARCHAR2(1);
	l_return_value  BOOLEAN := TRUE;
BEGIN
   	SELECT 'x'
        INTO l_dummy
	FROM hz_cust_site_uses_all
	WHERE site_use_id = p_ship_to_add_id
        AND site_use_code = 'SHIP_TO';
      -- and ((active_end_date is null) OR (active_end_date >= sysdate));
	RETURN l_return_value;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    IF ( p_stack_err_msg = TRUE ) THEN
	FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_SHIP_TO_ADD_ID');
	FND_MESSAGE.SET_TOKEN('SHIP_TO_ADD_ID',p_ship_to_add_id );
	FND_MSG_PUB.Add;
    END IF;
    RETURN l_return_value;

END Is_ship_to_add_valid;


/*-----------------------------------------------------------*/
/* Procedure name: Acct_Rules_Check                          */
/* Description : Check if specific  party account            */
/*               rules are ok                                */
/*-----------------------------------------------------------*/

FUNCTION Acct_Rules_Check
(
   p_instance_party_id    IN   NUMBER ,
   p_relationship_type    IN   VARCHAR2,
   p_stack_err_msg        IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

 l_dummy          VARCHAR2(1);
 l_return_value   BOOLEAN := TRUE;
 l_party_relation VARCHAR2(30);

BEGIN

   SELECT 'x'
    INTO  l_dummy
    FROM  csi_ip_accounts
   WHERE  instance_party_id      = p_instance_party_id
     and  relationship_type_code = p_relationship_type
     and ((active_end_date is null) OR (active_end_date > sysdate));
     IF ( p_stack_err_msg = TRUE ) THEN
        FND_MESSAGE.SET_NAME('CSI','CSI_API_DUP_ACCT_TYPE');
        FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE_CODE',p_relationship_type);
	FND_MSG_PUB.Add;
     END IF;

        -- Vaidate if owner accounts are created, the party is also an owner
        l_party_relation := CSI_Instance_parties_vld_pvt.Get_Party_relation
                         (p_Instance_party_id);

        IF ((p_relationship_type = 'OWNER')
           AND (l_party_relation <> 'OWNER'))  THEN
          IF ( p_stack_err_msg = TRUE ) THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_OWNER_ACCT_REQ_OWNER_PTY');
            FND_MSG_PUB.Add;
          END IF;
        END IF;
   RETURN l_return_value;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
    l_return_value := FALSE;
   RETURN l_return_value;
END Acct_Rules_Check;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Party_Contact_Exists                   */
/* Description : Check if the Party Contact                  */
/*                     already exists                        */
/*-----------------------------------------------------------*/

FUNCTION Is_Party_Contact_Exists
(    p_contact_ip_id       IN      NUMBER      ,
    p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN IS

 l_inst_party_id NUMBER;
 l_return_value  BOOLEAN := TRUE;

BEGIN
	SELECT instance_party_id
        INTO l_inst_party_id
	FROM csi_i_parties
	WHERE contact_ip_id = p_contact_ip_id
        AND   contact_flag  = 'Y';

        l_return_value  := FALSE;
        IF ( p_stack_err_msg = TRUE ) THEN
	  FND_MESSAGE.SET_NAME('CSI','CSI_API_PTY_CONTACT_EXISTS');
	  FND_MSG_PUB.Add;
        END IF;
        RETURN l_return_value;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := TRUE;
    RETURN l_return_value;
  WHEN TOO_MANY_ROWS THEN
    l_return_value  := FALSE;
    IF ( p_stack_err_msg = TRUE ) THEN
	  FND_MESSAGE.SET_NAME('CSI','CSI_API_PTY_CONTACT_EXISTS');
	  FND_MSG_PUB.Add;
    END IF;
    RETURN l_return_value;
END Is_Party_Contact_Exists;


/*-----------------------------------------------------------*/
/* Procedure name: Get_Party_relation                        */
/* Description : Get the Party relationship type             */
/*-----------------------------------------------------------*/

FUNCTION Get_Party_relation
( p_Instance_party_id     IN      NUMBER,
  p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
 ) RETURN VARCHAR2 IS

   l_rel_type_code    VARCHAR2(30);
BEGIN
    SELECT relationship_type_code
      INTO l_rel_type_code
     FROM csi_i_parties
    WHERE instance_party_id = p_Instance_party_id;
    RETURN l_rel_type_code;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF ( p_stack_err_msg = TRUE ) THEN
	  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
	  FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_instance_party_id);
	  FND_MSG_PUB.Add;
    END IF;
    RETURN NULL;
END Get_Party_relation;


/*-----------------------------------------------------------*/
/* Procedure name: Get_Party_Record                          */
/* Description : Get Party Record for the account            */
/*-----------------------------------------------------------*/

FUNCTION Get_Party_Record
( p_Instance_party_id     IN      NUMBER,
  p_party_rec             OUT NOCOPY    csi_datastructures_pub.party_rec,
  p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

BEGIN
    SELECT
      instance_party_id                  ,
      instance_id                        ,
      party_source_table                 ,
      party_id                           ,
      relationship_type_code             ,
      contact_flag                       ,
      contact_ip_id                      ,
      active_start_date                  ,
      active_end_date                    ,
      context                            ,
      attribute1                         ,
      attribute2                         ,
      attribute3                         ,
      attribute4                         ,
      attribute5                         ,
      attribute6                         ,
      attribute7                         ,
      attribute8                         ,
      attribute9                         ,
      attribute10                        ,
      attribute11                        ,
      attribute12                        ,
      attribute13                        ,
      attribute14                        ,
      attribute15                        ,
      object_version_number              ,
      primary_flag                       ,
      preferred_flag
    INTO
      p_party_rec.instance_party_id                  ,
      p_party_rec.instance_id                        ,
      p_party_rec.party_source_table                 ,
      p_party_rec.party_id                           ,
      p_party_rec.relationship_type_code             ,
      p_party_rec.contact_flag                       ,
      p_party_rec.contact_ip_id                      ,
      p_party_rec.active_start_date                  ,
      p_party_rec.active_end_date                    ,
      p_party_rec.context                            ,
      p_party_rec.attribute1                         ,
      p_party_rec.attribute2                         ,
      p_party_rec.attribute3                         ,
      p_party_rec.attribute4                         ,
      p_party_rec.attribute5                         ,
      p_party_rec.attribute6                         ,
      p_party_rec.attribute7                         ,
      p_party_rec.attribute8                         ,
      p_party_rec.attribute9                         ,
      p_party_rec.attribute10                        ,
      p_party_rec.attribute11                        ,
      p_party_rec.attribute12                        ,
      p_party_rec.attribute13                        ,
      p_party_rec.attribute14                        ,
      p_party_rec.attribute15                        ,
      p_party_rec.object_version_number              ,
      p_party_rec.primary_flag                       ,
      p_party_rec.preferred_flag
    FROM  csi_i_parties
    WHERE instance_party_id = p_Instance_party_id;
    RETURN TRUE;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF ( p_stack_err_msg = TRUE ) THEN
	  FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_INST_PARTY_ID');
	  FND_MESSAGE.SET_TOKEN('INSTANCE_PARTY_ID',p_instance_party_id);
	  FND_MSG_PUB.Add;
    END IF;
    RETURN FALSE;
END Get_Party_Record;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Account_Expired                        */
/* Description : Is the account expired                      */
/*-----------------------------------------------------------*/

FUNCTION Is_Account_Expired
  (p_party_account_rec    IN  csi_datastructures_pub.party_account_rec
  ,p_stack_err_msg        IN  BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN IS

 l_dummy          VARCHAR2(1);
 l_return_value   BOOLEAN := TRUE;

BEGIN

   SELECT 'x'
    INTO  l_dummy
    FROM  csi_ip_accounts
   WHERE instance_party_id      = p_party_account_rec.instance_party_id
     AND party_account_id       = p_party_account_rec.party_account_id
     AND relationship_type_code = p_party_account_rec.relationship_type_code
     AND active_start_date      = p_party_account_rec.active_start_date
     AND active_end_date        < sysdate
     AND decode(p_party_account_rec.bill_to_address,
            NULL, NVL(bill_to_address, 1),
            bill_to_address)     = NVL(p_party_account_rec.bill_to_address, 1)
     AND decode(p_party_account_rec.ship_to_address,
            NULL, NVL(ship_to_address, 1),
             ship_to_address)     = NVL(p_party_account_rec.ship_to_address, 1)
     AND decode(p_party_account_rec.context,
            NULL, NVL(context, '1'),
                   context)     = NVL(p_party_account_rec.context, '1')
     AND decode(p_party_account_rec.attribute1,
            NULL, NVL(attribute1, '1'),
                   attribute1)     = NVL(p_party_account_rec.attribute1, '1')
     AND decode(p_party_account_rec.attribute2,
            NULL, NVL(attribute2, '1'),
                   attribute2)     = NVL(p_party_account_rec.attribute2, '1')
     AND decode(p_party_account_rec.attribute3,
            NULL, NVL(attribute3, '1'),
                   attribute3)     = NVL(p_party_account_rec.attribute3, '1')
     AND decode(p_party_account_rec.attribute4,
            NULL, NVL(attribute4, '1'),
                   attribute4)     = NVL(p_party_account_rec.attribute4, '1')
     AND decode(p_party_account_rec.attribute5,
            NULL, NVL(attribute5, '1'),
                   attribute5)     = NVL(p_party_account_rec.attribute5, '1')
     AND decode(p_party_account_rec.attribute6,
            NULL, NVL(attribute6, '1'),
                   attribute6)     = NVL(p_party_account_rec.attribute6, '1')
     AND decode(p_party_account_rec.attribute7,
            NULL, NVL(attribute7, '1'),
                   attribute7)     = NVL(p_party_account_rec.attribute7, '1')
     AND decode(p_party_account_rec.attribute8,
            NULL, NVL(attribute8, '1'),
                   attribute8)     = NVL(p_party_account_rec.attribute8, '1')
     AND decode(p_party_account_rec.attribute9,
            NULL, NVL(attribute9, '1'),
                   attribute9)     = NVL(p_party_account_rec.attribute9, '1')
     AND decode(p_party_account_rec.attribute10,
            NULL, NVL(attribute10, '1'),
                   attribute10)     = NVL(p_party_account_rec.attribute10, '1')
     AND decode(p_party_account_rec.attribute11,
            NULL, NVL(attribute11, '1'),
                   attribute11)     = NVL(p_party_account_rec.attribute11, '1')
     AND decode(p_party_account_rec.attribute12,
            NULL, NVL(attribute12, '1'),
                   attribute12)     = NVL(p_party_account_rec.attribute12, '1')
     AND decode(p_party_account_rec.attribute13,
            NULL, NVL(attribute13, '1'),
                   attribute13)     = NVL(p_party_account_rec.attribute13, '1')
     AND decode(p_party_account_rec.attribute14,
            NULL, NVL(attribute14, '1'),
                   attribute14)     = NVL(p_party_account_rec.attribute14, '1')
     AND decode(p_party_account_rec.attribute15,
            NULL, NVL(attribute15, '1'),
                   attribute15)     = NVL(p_party_account_rec.attribute15, '1');

    RETURN l_return_value;
/*
     AND bill_to_address        = p_party_account_rec.bill_to_address
     AND ship_to_address        = p_party_account_rec.ship_to_address

     AND context                = p_party_account_rec.context
     AND attribute1             = p_party_account_rec.attribute1
     AND attribute2             = p_party_account_rec.attribute2
     AND attribute3             = p_party_account_rec.attribute3
     AND attribute4             = p_party_account_rec.attribute4
     AND attribute5             = p_party_account_rec.attribute5
     AND attribute6             = p_party_account_rec.attribute6
     AND attribute7             = p_party_account_rec.attribute7
     AND attribute8             = p_party_account_rec.attribute8
     AND attribute9             = p_party_account_rec.attribute9
     AND attribute10            = p_party_account_rec.attribute10
     AND attribute11            = p_party_account_rec.attribute11
     AND attribute12            = p_party_account_rec.attribute12
     AND attribute13            = p_party_account_rec.attribute13
     AND attribute14            = p_party_account_rec.attribute14
     AND attribute15            = p_party_account_rec.attribute15;
*/

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    RETURN l_return_value;

END Is_Account_Expired;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Party_Expired                          */
/* Description : Is the party expired                        */
/*-----------------------------------------------------------*/

FUNCTION Is_Party_Expired
  (   p_party_rec                   IN  csi_datastructures_pub.party_rec
     ,p_stack_err_msg               IN  BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN IS
 l_dummy          VARCHAR2(1);
 l_return_value   BOOLEAN := TRUE;

BEGIN

  SELECT 'x'
    INTO l_dummy
    FROM csi_i_parties
   WHERE instance_id            = p_party_rec.instance_id
     AND party_source_table     = p_party_rec.party_source_table
     AND party_id               = p_party_rec.party_id
     AND relationship_type_code = p_party_rec.relationship_type_code
     AND contact_flag           = p_party_rec.contact_flag
     AND decode(p_party_rec.contact_ip_id,
           NULL, NVL(contact_ip_id, 1),
                 contact_ip_id) = NVL(p_party_rec.contact_ip_id, 1)
     AND active_start_date      = p_party_rec.active_start_date
     AND active_end_date        < sysdate
     AND decode(p_party_rec.context,
            NULL, NVL(context, '1'),
                   context)     = NVL(p_party_rec.context, '1')
     AND decode(p_party_rec.attribute1,
            NULL, NVL(attribute1, '1'),
                   attribute1)     = NVL(p_party_rec.attribute1, '1')
     AND decode(p_party_rec.attribute2,
            NULL, NVL(attribute2, '1'),
                   attribute2)     = NVL(p_party_rec.attribute2, '1')
     AND decode(p_party_rec.attribute3,
            NULL, NVL(attribute3, '1'),
                   attribute3)     = NVL(p_party_rec.attribute3, '1')
     AND decode(p_party_rec.attribute4,
            NULL, NVL(attribute4, '1'),
                   attribute4)     = NVL(p_party_rec.attribute4, '1')
     AND decode(p_party_rec.attribute5,
            NULL, NVL(attribute5, '1'),
                   attribute5)     = NVL(p_party_rec.attribute5, '1')
     AND decode(p_party_rec.attribute6,
            NULL, NVL(attribute6, '1'),
                   attribute6)     = NVL(p_party_rec.attribute6, '1')
     AND decode(p_party_rec.attribute7,
            NULL, NVL(attribute7, '1'),
                   attribute7)     = NVL(p_party_rec.attribute7, '1')
     AND decode(p_party_rec.attribute8,
            NULL, NVL(attribute8, '1'),
                   attribute8)     = NVL(p_party_rec.attribute8, '1')
     AND decode(p_party_rec.attribute9,
            NULL, NVL(attribute9, '1'),
                   attribute9)     = NVL(p_party_rec.attribute9, '1')
     AND decode(p_party_rec.attribute10,
            NULL, NVL(attribute10, '1'),
                   attribute10)     = NVL(p_party_rec.attribute10, '1')
     AND decode(p_party_rec.attribute11,
            NULL, NVL(attribute11, '1'),
                   attribute11)     = NVL(p_party_rec.attribute11, '1')
     AND decode(p_party_rec.attribute12,
            NULL, NVL(attribute12, '1'),
                   attribute12)     = NVL(p_party_rec.attribute12, '1')
     AND decode(p_party_rec.attribute13,
            NULL, NVL(attribute13, '1'),
                   attribute13)     = NVL(p_party_rec.attribute13, '1')
     AND decode(p_party_rec.attribute14,
            NULL, NVL(attribute14, '1'),
                   attribute14)     = NVL(p_party_rec.attribute14, '1')
     AND decode(p_party_rec.attribute15,
            NULL, NVL(attribute15, '1'),
                   attribute15)     = NVL(p_party_rec.attribute15, '1');

    RETURN l_return_value;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_return_value  := FALSE;
    RETURN l_return_value;

END Is_Party_Expired;


/*-----------------------------------------------------------*/
/* Procedure name: Transfer_Party_Rules                      */
/* Description : Expire accounts of the party if party is    */
/*               being changed                               */
/*-----------------------------------------------------------*/

PROCEDURE Transfer_Party_Rules
 (    p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_party_rec                   IN  csi_datastructures_pub.party_rec
     ,p_stack_err_msg               IN  BOOLEAN DEFAULT TRUE
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY VARCHAR2
     ,x_msg_count                   OUT NOCOPY NUMBER
     ,x_msg_data                    OUT NOCOPY VARCHAR2
 ) IS

   l_api_name      CONSTANT VARCHAR2(30)   := 'Transfer Party Rules ';
   l_api_version   CONSTANT NUMBER         := 1.0;
   l_csi_debug_level        NUMBER;
   l_msg_count              NUMBER;
   l_msg_index              NUMBER;
   l_party_account_rec      csi_datastructures_pub.party_account_rec;


  CURSOR GET_IP_ACCOUNT (i_inst_party_id   IN  NUMBER) IS
    SELECT ip_account_id,
           relationship_type_code, -- Added by sguthiva for bug 2307804
           party_account_id,       -- Added by sguthiva for bug 2307804
           object_version_number
    FROM csi_ip_accounts
    WHERE instance_party_id = i_inst_party_id
    AND (( ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE >= SYSDATE)) ;

BEGIN

        -- Standard Start of API savepoint
        -- SAVEPOINT  Transfer_Party_Rules;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version   ,
                                                p_api_version   ,
                                                l_api_name      ,
                                                g_pkg_name      )
        THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        -- Verify if the Party rel combination exists
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'Transfer_Party_Rules');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line( 'Transfer_Party_Rules:'||
                                                 p_api_version           ||'-'||
                                                 p_commit                ||'-'||
                                                 p_init_msg_list               );

            -- Dump the records in the log file
            csi_gen_utility_pvt.dump_party_rec(p_party_rec );
            csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;


     -- csi_party_relationships_pvt.g_force_expire_flag   := 'Y'; -- commented by sguthiva for bug 2307804
     -- Expire accounts for the party
      FOR C1 IN GET_IP_ACCOUNT(p_party_rec.instance_party_id)
      LOOP
        IF GET_IP_ACCOUNT%FOUND THEN
           l_party_account_rec.ip_account_id := C1.ip_account_id;
           l_party_account_rec.expire_flag := fnd_api.g_true; -- Added by sguthiva for bug 2307804
           l_party_account_rec.object_version_number := C1.object_version_number;
         -- Added by sguthiva for bug 2307804
          IF C1.relationship_type_code <> 'OWNER'
          THEN
          --End Addition by sguthiva for bug 2307804

           csi_party_relationships_pvt.expire_inst_party_account
           ( p_api_version                 => p_api_version
            ,p_commit                      => p_commit
            ,p_init_msg_list               => p_init_msg_list
            ,p_validation_level            => p_validation_level
            ,p_party_account_rec           => l_party_account_rec
            ,p_txn_rec                     => p_txn_rec
            ,x_return_status               => x_return_status
            ,x_msg_count                   => x_msg_count
            ,x_msg_data                    => x_msg_data       );

            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		 l_msg_index := 1;
                 l_msg_count := x_msg_count;
    	         WHILE l_msg_count > 0 LOOP
     		           x_msg_data := FND_MSG_PUB.GET(
    	       			           l_msg_index,
	     	  		           FND_API.G_FALSE);
	                   csi_gen_utility_pvt.put_line( 'message data = Error from csi_party_relationships_pvt.expire_inst_party_account');
	                   csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
   	    	           l_msg_index := l_msg_index + 1;
		           l_msg_count := l_msg_count - 1;
  	         END LOOP;
                 RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF; -- Added by sguthiva for bug 2307804
         END IF;
       END LOOP;
     -- csi_party_relationships_pvt.g_force_expire_flag   := 'N'; -- commented by sguthiva for bug 2307804


       -- Check if the party in question has a contact
       /* The following code has been added for bug 2127250 */
       IF   p_party_rec.contact_ip_id IS NOT NULL
        AND p_party_rec.contact_ip_id <> fnd_api.g_miss_num
       THEN
       /* End of addition  for bug 2127250 */
        IF (CSI_Instance_parties_vld_pvt.Is_Party_Contact_Exists
                     (p_party_rec.contact_ip_id,
                     TRUE)) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
       END IF;

     -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;


        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- ROLLBACK TO Transfer_Party_Rules;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                -- ROLLBACK TO Transfer_Party_Rules;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data );
        WHEN OTHERS THEN
                -- ROLLBACK TO Transfer_Party_Rules;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data  );

END Transfer_Party_Rules;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Preferred_Contact_Pty                  */
/* Description : Check if Preferred party exist for the      */
/*                current party relationship                 */
/*-----------------------------------------------------------*/

FUNCTION Is_Preferred_Contact_Pty
( p_Instance_id         IN      NUMBER,
  p_relationship_type   IN      VARCHAR2    ,
  p_start_date          IN      DATE        ,
  p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

 l_dummy         VARCHAR(1);
 l_return_value  BOOLEAN := TRUE;

   CURSOR C1 IS
    SELECT 'x'
    FROM csi_i_parties
   WHERE instance_id = p_Instance_id
    -- AND  relationship_type_code = p_relationship_type
    AND  preferred_flag = 'Y'
    AND  contact_flag = 'Y'
    AND ((active_end_date is null) OR (active_end_date >= sysdate))
    AND NVL(active_end_date, SYSDATE) >= DECODE(active_end_date, NULL, SYSDATE,  NVL(p_start_date, FND_API.G_MISS_DATE));
BEGIN
    OPEN C1;
    FETCH C1 INTO l_dummy;
    IF C1%FOUND THEN
       IF ( p_stack_err_msg = TRUE ) THEN
     	  FND_MESSAGE.SET_NAME('CSI','CSI_API_PREFERRED_PTY_EXISTS');
    	  FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
    	  FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE',p_relationship_type);
	  FND_MSG_PUB.Add;
      END IF;
    ELSE
       l_return_value  := FALSE;
    END IF;
    CLOSE C1;
  RETURN l_return_value;
 EXCEPTION
  WHEN OTHERS THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
END Is_Preferred_Contact_Pty;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Primary_Contact_Pty                    */
/* Description : Check if Primary party exist for the        */
/*                current party relationship                 */
/*-----------------------------------------------------------*/

FUNCTION Is_Primary_Contact_Pty
( p_Instance_id         IN      NUMBER,
  p_contact_ip_id       IN      NUMBER,
  p_relationship_type   IN      VARCHAR2    ,
  p_start_date          IN      DATE        ,
  p_end_date            IN      DATE        ,
  p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

 l_dummy         VARCHAR(1);
 l_return_value  BOOLEAN := TRUE;

   CURSOR C1 IS
    SELECT 'x'
    FROM csi_i_parties
   WHERE instance_id = p_Instance_id
    AND  relationship_type_code = p_relationship_type
    AND  primary_flag = 'Y'
    AND  contact_flag = 'Y'
    AND  contact_ip_id = p_contact_ip_id
    AND ((active_end_date is null) OR (active_end_date > p_start_date));
   --  AND  active_start_date < p_end_date;  --sk added
   -- AND ((active_end_date is null) OR (active_end_date >= sysdate))
   -- AND NVL(active_end_date, SYSDATE) >= DECODE(active_end_date, NULL, SYSDATE,  NVL(p_start_date, FND_API.G_MISS_DATE));
BEGIN
    OPEN C1;
    FETCH C1 INTO l_dummy;
    IF C1%FOUND THEN
       IF ( p_stack_err_msg = TRUE ) THEN
     	  FND_MESSAGE.SET_NAME('CSI','CSI_API_PRIMARY_PTY_EXISTS');
    	  FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
    	  FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE',p_relationship_type);
	  FND_MSG_PUB.Add;
      END IF;
    ELSE
       l_return_value  := FALSE;
    END IF;
    CLOSE C1;
  RETURN l_return_value;
 EXCEPTION
  WHEN OTHERS THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
END Is_Primary_Contact_Pty;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Preferred_Pty                          */
/* Description : Check if Preferred party exist for the      */
/*                current party relationship                 */
/*-----------------------------------------------------------*/

FUNCTION Is_Preferred_Pty
( p_Instance_id         IN      NUMBER,
  p_relationship_type   IN      VARCHAR2    ,
  p_start_date          IN      DATE        ,
  p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

 l_dummy         VARCHAR(1);
 l_return_value  BOOLEAN := TRUE;

   CURSOR C1 IS
    SELECT 'x'
    FROM csi_i_parties
   WHERE instance_id = p_Instance_id
    -- AND  relationship_type_code = p_relationship_type
    AND  preferred_flag = 'Y'
    AND  contact_flag <> 'Y'
    AND ((active_end_date is null) OR (active_end_date >= sysdate))
    AND NVL(active_end_date, SYSDATE) >= DECODE(active_end_date, NULL, SYSDATE,  NVL(p_start_date, FND_API.G_MISS_DATE));


BEGIN
    OPEN C1;
    FETCH C1 INTO l_dummy;
    IF C1%FOUND THEN
       IF ( p_stack_err_msg = TRUE ) THEN
     	  FND_MESSAGE.SET_NAME('CSI','CSI_API_PREFERRED_PTY_EXISTS');
    	  FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
    	  FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE',p_relationship_type);
	  FND_MSG_PUB.Add;
      END IF;
    ELSE
       l_return_value  := FALSE;
    END IF;
    CLOSE C1;
  RETURN l_return_value;
 EXCEPTION
  WHEN OTHERS THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
END Is_Preferred_Pty;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Primary_Pty                            */
/* Description : Check if Primary party exist for the        */
/*                current party relationship                 */
/*-----------------------------------------------------------*/

FUNCTION Is_Primary_Pty
( p_Instance_id         IN      NUMBER,
  p_relationship_type   IN      VARCHAR2    ,
  p_start_date          IN      DATE        ,
  p_end_date            IN      DATE        ,
  p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN IS

 l_dummy         VARCHAR(1);
 l_return_value  BOOLEAN := TRUE;

   CURSOR C1 IS
    SELECT 'x'
    FROM  csi_i_parties
    WHERE instance_id = p_Instance_id
    AND   relationship_type_code = p_relationship_type
    AND   primary_flag = 'Y'
    AND   contact_flag <> 'Y'
    AND ((active_end_date IS NULL) OR (active_end_date > p_start_date));
   -- AND  active_start_date < p_end_date ; sk commented this for bug 2077093.
   -- AND ((active_end_date is null) OR (active_end_date >= sysdate)) --sk commented
   -- AND NVL(active_end_date, SYSDATE) >= DECODE(active_end_date, NULL, SYSDATE,  NVL(p_start_date, FND_API.G_MISS_DATE));
BEGIN
    OPEN C1;
    FETCH C1 INTO l_dummy;
    IF C1%FOUND THEN
       IF ( p_stack_err_msg = TRUE ) THEN
     	  FND_MESSAGE.SET_NAME('CSI','CSI_API_PRIMARY_PTY_EXISTS');
    	  FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id);
    	  FND_MESSAGE.SET_TOKEN('RELATIONSHIP_TYPE',p_relationship_type);
	      FND_MSG_PUB.Add;
      END IF;
    ELSE
       l_return_value  := FALSE;
    END IF;
    CLOSE C1;
  RETURN l_return_value;
 EXCEPTION
  WHEN OTHERS THEN
    l_return_value  := FALSE;
    RETURN l_return_value;
END Is_Primary_Pty;




END CSI_Instance_parties_vld_pvt;

/
