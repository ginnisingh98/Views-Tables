--------------------------------------------------------
--  DDL for Package Body QOT_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QOT_UTILITY_PVT" AS
/* $Header: qotvutlb.pls 120.0.12010000.2 2009/08/14 12:23:38 rassharm ship $ */
-- Start of Comments
-- Package name     : QOT_UTILITY_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

FUNCTION GET_CONTRACT_TERMS_ACCESS
(
 	P_QUOTE_HEADER_ID	IN	NUMBER,
	P_USER_ID			IN	NUMBER
) RETURN VARCHAR2
AS
	CURSOR C_user_resource_id (pc_user_id NUMBER) IS
	SELECT resource_id
	FROM jtf_rs_resource_extns
	WHERE user_id = pc_user_id
	AND SYSDATE BETWEEN start_date_active AND NVL(end_date_active, SYSDATE);

	CURSOR C_quote_header (pc_quote_header_id IN NUMBER)
	IS
	SELECT max_version_flag, price_request_id, quote_status_id, quote_number
	FROM ASO_QUOTE_HEADERS_ALL
	WHERE quote_header_id = pc_quote_header_id;

	CURSOR C_quote_status (pc_status_id IN NUMBER)
	IS
	SELECT update_allowed_flag
	FROM ASO_QUOTE_STATUSES_B
	WHERE quote_status_id = pc_status_id;

	l_max_ver_flag		  VARCHAR2(1);
	l_upd_allowed_flag	  VARCHAR2(1);
	l_qot_sec_enabled	  VARCHAR2(1);
	l_qot_access		  VARCHAR2(10);
	l_status_override	  VARCHAR2(1);
	l_resource_id		  NUMBER;
	l_price_request_id	  NUMBER;
	l_status_id			  NUMBER;
	l_qot_num		  	  NUMBER;

	l_debug                   VARCHAR2(1);

BEGIN
	l_debug := ASO_QUOTE_UTIL_PVT.is_debug_enabled;
--	IF l_debug = 'Y' THEN
--	  ASO_QUOTE_UTIL_PVT.Enable_Debug_Pvt;
--	  ASO_QUOTE_UTIL_PVT.Debug('QOT_CONTRACTS_ACCESS.Get_Contracts_Acess Begins');
--	END IF;

	l_qot_sec_enabled := nvl(fnd_profile.value('ASO_ENABLE_SECURITY_CHECK'),'N');

	OPEN C_user_resource_id(p_user_id);
	FETCH C_user_resource_id INTO l_resource_id;
	CLOSE C_user_resource_id;

	--If security is ON and resource_id is NULL, return 'N'
	IF(l_qot_sec_enabled = 'Y' AND l_resource_id IS NULL) THEN
		--dbms_output.put_line('Security is ON but resource Id is NULL..so NO Access');
		RETURN 'N';
	END IF;

	OPEN C_quote_header(p_quote_header_id);
	FETCH C_quote_header INTO l_max_ver_flag, l_price_request_id, l_status_id, l_qot_num;
	CLOSE C_quote_header;

	--If quote is NOT highest version or is submitted for batch pricing then return 'N'
	IF(l_max_ver_flag <> 'Y' OR l_price_request_id IS NOT NULL) THEN
		--dbms_output.put_line('Not highest version or submitted for batch pricing..so NO Access');
		RETURN 'N';
	END IF;

	OPEN C_quote_status(l_status_id);
	FETCH C_quote_status INTO l_upd_allowed_flag;
	CLOSE C_quote_status;

	l_status_override := nvl(fnd_profile.value('ASO_STATUS_OVERRIDE'),'N');

	--dbms_output.put_line('ASO_STATUS_OVERRIDE ' || l_status_override);

	IF(l_upd_allowed_flag = 'N') THEN
		--dbms_output.put_line('Quote is in Read-only Status');
		IF (l_qot_sec_enabled = 'Y') THEN
			--dbms_output.put_line('Security Enabled..');
			l_qot_access := ASO_SECURITY_INT.Get_Quote_Access(l_resource_id, l_qot_num);
			--dbms_output.put_line('Quote Access ' || l_qot_access);
			IF (l_status_override <> 'Y' AND (l_qot_access = 'UPDATE' OR l_qot_access = 'READ')) THEN
				--dbms_output.put_line('Quote Access is Update or Read and STatus Override is No..View Access');
				RETURN 'V';
			END IF;
			IF (l_status_override <> 'Y' AND l_qot_access = 'NONE') THEN
				--dbms_output.put_line('Quote Access is NONE..so return N');
				RETURN 'N';
			END IF;
		ELSE
			--dbms_output.put_line('Quote is read-only status but security is off..so return V');
                        -- Added for bug 8717880
			if l_status_override ='Y' then
			  RETURN 'U';
                        else
			  RETURN 'V';
			END IF;
		END IF;
	ELSE
	IF (l_upd_allowed_flag = 'Y') THEN
		--dbms_output.put_line('Quote is in Update Status');
		IF (l_qot_sec_enabled = 'Y') THEN
			l_qot_access := ASO_SECURITY_INT.Get_Quote_Access(l_resource_id, l_qot_num);
			--dbms_output.put_line('Quote Access ' || l_qot_access);
		   IF (l_status_override <> 'Y' AND l_qot_access = 'UPDATE') THEN
			--dbms_output.put_line('Quote Access is Update and STatus Override is No..Update Access');
			RETURN 'U';
		   END IF;
		   IF (l_qot_access = 'READ') THEN
			--dbms_output.put_line('Quote Access is Read..View Access');
		   	  RETURN 'V';	--??
		   END IF;
		   IF (l_qot_access = 'NONE') THEN
				--dbms_output.put_line('Quote Access is NONE..so return N');
		   	  RETURN 'N';
		   END IF;
		ELSE
			--dbms_output.put_line('Quote is in Update status but security is off..so return U');
			RETURN 'U';
		END IF;
	END IF;
END IF;
END GET_CONTRACT_TERMS_ACCESS;

END QOT_UTILITY_PVT;

/
