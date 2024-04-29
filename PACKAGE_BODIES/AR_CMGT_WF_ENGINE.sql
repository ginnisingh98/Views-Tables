--------------------------------------------------------
--  DDL for Package Body AR_CMGT_WF_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_WF_ENGINE" AS
 /* $Header: ARCMGWFB.pls 120.31.12010000.25 2010/04/20 22:20:41 rravikir ship $  */

pg_wf_debug VARCHAR2(1) := ar_cmgt_util.get_wf_debug_flag;

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.wf_debug ('AR_CMGT_WF_ENGINE',p_message_name );
END;


PROCEDURE raise_recco_event (p_case_folder_id  IN  NUMBER) AS
    l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_exist                                 VARCHAR2(1);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.cmgt.CreditRequestRecommendation.implement';
    l_credit_request_id                     NUMBER;
    l_source_name                           AR_CMGT_CREDIT_REQUESTS.source_name%TYPE;
    l_source_column1                        AR_CMGT_CREDIT_REQUESTS.source_column1%TYPE;
    l_source_column2                        AR_CMGT_CREDIT_REQUESTS.source_column2%TYPE;
    l_source_column3                        AR_CMGT_CREDIT_REQUESTS.source_column3%TYPE;
    l_source_user_id                        ar_cmgt_credit_requests.SOURCE_USER_ID%type;
    l_source_resp_id                        ar_cmgt_credit_requests.SOURCE_RESP_ID%type;
    l_source_resp_appln_id                  ar_cmgt_credit_requests.SOURCE_RESP_APPLN_ID%type;
    l_source_security_group_id              ar_cmgt_credit_requests.SOURCE_SECURITY_GROUP_ID%type;
    l_source_org_id                         ar_cmgt_credit_requests.SOURCE_ORG_ID%type;
    l_case_folder_exists                    VARCHAR2(1);

CURSOR get_case_folder_info (p_cf_id IN NUMBER) IS
SELECT cr.credit_request_id,
       cr.source_name, cr.source_column1,
       cr.source_column2, cr.source_column3,
       cr.source_user_id,
       cr.source_resp_id,
       cr.source_resp_appln_id,
       cr.source_security_group_id,
       cr.source_org_id
FROM  ar_cmgt_credit_requests cr,
      ar_cmgt_case_folders cf
WHERE case_folder_id = p_cf_id
  and cr.credit_request_id = cf.credit_request_id;

BEGIN
   SAVEPOINT  raise_cr_recco_event;
    -- Test if there are any active subscritions
    -- if it is the case then execute the subscriptions

    l_exist := AR_CMGT_EVENT_PKG.exist_subscription( l_event_name );

       OPEN get_case_folder_info(p_case_folder_id);
       FETCH get_case_folder_info INTO l_credit_request_id,
                                       l_source_name,
                                       l_source_column1,
                                       l_source_column2,
                                       l_source_column3,
                                       l_source_user_id,
                                       l_source_resp_id,
                                       l_source_resp_appln_id,
                                       l_source_security_group_id,
                                       l_source_org_id  ;
         l_case_folder_exists := 'Y';

        IF get_case_folder_info%NOTFOUND THEN
          l_case_folder_exists := 'N';
        END IF;

        CLOSE get_case_folder_info ;


    IF l_exist = 'Y' AND
       l_case_folder_exists = 'Y' THEN

        --Get the item key
        l_key := AR_CMGT_EVENT_PKG.item_key( p_event_name => l_event_name,
                                             p_unique_identifier => p_case_folder_id );


        -- initialization of object variables
        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        ar_cmgt_event_pkg.AddParamEnvToList(l_list);


        -- add more parameters to the parameters list

        wf_event.AddParameterToList(p_name => 'CREDIT_REQUEST_ID',
                           p_value => l_credit_request_id,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'CASE_FOLDER_ID',
                           p_value => p_case_folder_id,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'SOURCE_NAME',
                           p_value => l_source_name,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'SOURCE_COLUMN1',
                           p_value => l_source_column1,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_COLUMN2',
                           p_value => l_source_column2,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_COLUMN3',
                           p_value => l_source_column3,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'SOURCE_USER_ID',
                           p_value => l_source_user_id,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'SOURCE_RESP_ID',
                           p_value => l_source_resp_id,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_RESP_APPLN_ID',
                           p_value => l_source_resp_appln_id,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_SECURITY_GROUP_ID',
                           p_value => l_source_security_group_id,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_ORG_ID',
                           p_value => l_source_org_id,
                           p_parameterlist => l_list);
        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;

    END IF;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK TO raise_cr_recco_event;
  raise;
END raise_recco_event;



procedure get_employee_details(
        p_employee_id        IN         NUMBER,
        p_user_name          OUT NOCOPY        VARCHAR2,
        p_display_name       OUT NOCOPY        VARCHAR2) AS
BEGIN
        wf_directory.getusername ('PER', p_employee_id,
                                  p_user_name,
                                  p_display_name);
        EXCEPTION
            WHEN OTHERS
            THEN
                wf_core.context ('AR_CMGT_WF_ENGINE','GET_EMPLOYEE_DETAILS',
                                 sqlerrm);
                raise;
END;

PROCEDURE check_required_dnb_data_points (
        p_case_folder_id        IN      NUMBER,
        p_check_list_id         IN      NUMBER,
        p_errmsg                OUT NOCOPY     VARCHAR2,
        p_resultout             OUT NOCOPY     VARCHAR2 ) IS

	cnt			NUMBER;
    l_data_point_id                 ar_cmgt_data_points_vl.data_point_id%type;
CURSOR c_dnb_required_data IS
    SELECT data_point_id
    FROM   ar_cmgt_check_list_dtls
    WHERE  data_point_id between 10000  and 20000
    AND    check_list_id = p_check_list_id
    AND    required_flag = 'Y';

-- need to find out NOCOPY the table involved for the data points
CURSOR c_dnb_source_table IS
    SELECT distinct source_table_name
    FROM   ar_cmgt_dnb_elements_vl
    WHERE  source_table_name <> 'HZ_FINANCIAL_NUMBERS'   -- this table is accessed via hz_financial_reports
    and    data_element_id in (
            SELECT data_element_id
            FROM   ar_cmgt_dnb_mappings
            WHERE  data_point_id = l_data_point_id);


BEGIN
    p_resultout := 0;
    FOR c_dnb_required_data_rec IN c_dnb_required_data
    LOOP
        l_data_point_id := c_dnb_required_data_rec.data_point_id;
        FOR c_dnb_source_table_rec IN c_dnb_source_table
        LOOP
            BEGIN
                SELECT  1
                INTO    cnt
                FROM    ar_cmgt_cf_dnb_dtls
                WHERE   case_folder_id = p_case_folder_id
                AND     source_table_name = c_dnb_source_table_rec.source_table_name;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        p_resultout := 2;
                        p_errmsg := 'Required DNB Data Points missing';
                        return;
                    WHEN TOO_MANY_ROWS THEN
                        NULL;
            END;
        END LOOP;
    END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
           p_resultout := 1;
           p_errmsg := 'Sql Error in check_required_dnb_data_points '||sqlerrm;
           return;


END;

PROCEDURE validate_reference_data_points (
        p_credit_request_id     IN      NUMBER,
        p_check_list_id         IN      NUMBER,
        p_errmsg                OUT NOCOPY     VARCHAR2,
        p_resultout             OUT NOCOPY     VARCHAR2) IS

/*******************************************************
    Data Points Id                  Name
      86                         Bank Reference
      87                         Trade Reference
      88                         Gurantors
********************************************************/
CURSOR c_ref_data_points IS
            SELECT data_point_id, number_of_references
            FROM   ar_cmgt_check_list_dtls
            WHERE  check_list_id = p_check_list_id
            AND    data_point_id IN (86,87,88)
            AND    required_flag = 'Y';

l_cnt                   NUMBER := 0;
BEGIN
    p_resultout := 0;
    FOR c_ref_data_points_rec IN c_ref_data_points
    LOOP
         -- Get the No. of Bank reference Data
         IF c_ref_data_points_rec.data_point_id = 86
         THEN
            BEGIN
                SELECT COUNT(*)
                INTO   l_cnt
                FROM   ar_cmgt_bank_ref_data
                WHERE  credit_request_id = p_credit_request_id;

                IF l_cnt < c_ref_data_points_rec.number_of_references
                THEN
                    p_resultout := 2;
                    return;
                END IF;
            END;
         ELSIF c_ref_data_points_rec.data_point_id = 87
         THEN
            BEGIN
                SELECT COUNT(*)
                INTO   l_cnt
                FROM   ar_cmgt_trade_ref_data
                WHERE  credit_request_id = p_credit_request_id;

                IF l_cnt < c_ref_data_points_rec.number_of_references
                THEN
                    p_resultout := 2;
                    return;
                END IF;
            END;
         ELSIF c_ref_data_points_rec.data_point_id = 88
         THEN
            BEGIN
                SELECT COUNT(*)
                INTO   l_cnt
                FROM   ar_cmgt_guarantor_data
                WHERE  credit_request_id = p_credit_request_id;

                IF l_cnt < c_ref_data_points_rec.number_of_references
                THEN
                    p_resultout := 2;
                    return;
                END IF;
            END;
         END IF;
    END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            p_errmsg := 'Error in ar_cmgt_wf_engine.validate_reference_data_points '|| sqlerrm;
            p_resultout := 1;
            return;
END;
PROCEDURE VALIDATE_REQUIRED_DATA_POINTS (
        p_credit_request_id     IN      NUMBER,
        p_case_folder_id        IN      NUMBER,
        p_check_list_id         IN      NUMBER default NULL,
        p_errmsg                OUT NOCOPY     VARCHAR2,
        p_resultout             OUT NOCOPY     VARCHAR2) AS

        l_check_list_id                 NUMBER;
        l_cnt                           NUMBER;
/**********************************************
    p_resultout = 0 means Sucess
    p_resultout = 1 means fatal error
    p_resultout = 2 Missing values for required data points
***********************************************/

BEGIN
         p_resultout := 0;
        IF p_check_list_id IS NULL
        THEN
            BEGIN
                SELECT check_list_id
                INTO   l_check_list_id
                FROM   ar_cmgt_case_folders
                WHERE  case_folder_id = p_case_folder_id
                AND    type = 'CASE';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    p_resultout := 1;
                    p_errmsg := 'Check List Id not found';
                    return;
                WHEN OTHERS THEN
                    p_resultout := 1;
                    p_errmsg := sqlerrm;
                    return;
            END;
        END IF;
        l_check_list_id := p_check_list_id;
        BEGIN
            SELECT 1 into l_cnt
            FROM ar_cmgt_check_list_dtls a, ar_cmgt_cf_dtls b,
                 ar_cmgt_data_points_vl dp
            WHERE  a.check_list_id = l_check_list_id
            AND    b.case_folder_id = p_case_folder_id
            AND    a.data_point_id  = b.data_point_id
            AND    dp.data_point_id = a.data_point_id
            AND    dp.data_point_category not in ('AGING','INVOICE','DNB') -- Added 'DNB' for bug 8632968 in place of commented code below
            AND    a.required_flag = 'Y'
            --AND    a.data_point_id < 10000  -- Commented for bug 8632968
            and    b.data_point_value is null;

            p_resultout := 2; -- one row exist so validation failed

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_resultout := 0; -- success
                -- need to move this procedure to util.
                validate_reference_data_points(
                            p_credit_request_id,
                            p_check_list_id,
                            p_errmsg,
                            p_resultout);
                IF p_resultout = 0
                THEN
                    check_required_dnb_data_points(
                               p_case_folder_id,
					           p_check_list_id,
					           p_errmsg,
					           p_resultout);
                END IF;
            WHEN TOO_MANY_ROWS THEN
                p_resultout := 2; -- all required values does not exist
            WHEN OTHERS THEN
                p_resultout := 1;
                p_errmsg := sqlerrm;

        END;
END;

PROCEDURE create_creditManagement_role (
    itemtype        in      varchar2,
    itemkey         in      varchar2 ) IS

    l_role_name                 VARCHAR2(30):= 'AR_CMGT_CREDIT_ANALYST_ROLE';
    l_role_display_name         VARCHAR2(240) := 'Credit Analyst Role';
    l_user_name                 fnd_user.user_name%type;
    l_display_name              per_people_f.full_name%type;

    CURSOR c_get_resource_id IS
        SELECT c.resource_id, c.source_id --employee id
        FROM  jtf_rs_role_relations a,
              jtf_rs_roles_vl b,
              jtf_rs_resource_extns_vl c
        WHERE a.role_resource_type = 'RS_INDIVIDUAL'
        AND   a.role_resource_id = c.resource_id
        AND   a.role_id = b.role_id
        AND   b.role_code = 'CREDIT_ANALYST'
        AND   c.category = 'EMPLOYEE'
        AND   nvl(a.delete_flag,'N') <> 'Y';

BEGIN
        -- this role will be used to re-assign credit analyst by Credit Scheduler
        -- in case credit analyst is not available. Credit Analyst is defined in
        -- resource manger as role_type CREDIT_ANALYST.

        l_role_display_name := wf_directory.getRoleDisplayName (
                                p_role_name => 'AR_CMGT_CREDIT_ANALYST_ROLE');
        IF l_role_display_name IS NULL
        THEN
            l_role_display_name  := 'Credit Analyst Role';
            wf_directory.CreateAdHocRole
                        (role_name          => l_role_name,
                         role_display_name  => l_role_display_name,
                         expiration_date    => to_date('31/12/4712','DD/MM/RRRR'));
        END IF;

        WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => itemkey,
                                aname    => 'CREDIT_ANALYST_ROLE',
                                avalue   => 'AR_CMGT_CREDIT_ANALYST_ROLE');

        -- get the resource id for all Credit Analysts
        FOR c_get_resurce_rec IN  c_get_resource_id
        LOOP
            get_employee_details(c_get_resurce_rec.source_id,
                                 l_user_name,
                                 l_display_name);
            -- first check whether this is the active user or not
            IF  wf_directory.useractive(l_user_name)
            THEN
                --if user already added then it will raise an exception
                --if not then it will add the user.
                BEGIN
                    wf_directory.AddUsersToAdHocRole
                            ('AR_CMGT_CREDIT_ANALYST_ROLE',l_user_name);
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
                END;
            END IF;
        END LOOP;

END;

PROCEDURE POST_CREDIT_ANALYST_ASSIGNMENT (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

    l_employee_id           fnd_user.employee_id%type;
    l_resource_id           jtf_rs_resource_extns_vl.resource_id%type;
    l_notification_id       NUMBER;
    l_user_name             VARCHAR2(60);
    l_display_name          VARCHAR2(240);
    l_failure_function      VARCHAR2(60);

BEGIN
    IF funcmode = 'TRANSFER' OR funcmode = 'FORWARD'
    THEN

        -- get resource id for credit analyst user
        BEGIN
            SELECT  employee_id
            INTO    l_employee_id
            FROM    FND_USER
            WHERE   user_name = wf_engine.context_text;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    wf_core.context('AR_CMGT_WF_ENGINE','GET_CREDIT_ANALYST',itemtype, itemkey,
                          'Employee Id Not found for User:'||wf_engine.context_text ||' '||'Sqlerror '||sqlerrm);
                    raise;
                WHEN OTHERS THEN
                    wf_core.context('AR_CMGT_WF_ENGINE','GET_CREDIT_ANALYST',itemtype, itemkey,
                          'Sqlerror while getiing Employee Id '||sqlerrm);
                    raise;
        END;
        BEGIN
            SELECT c.resource_id
            INTO   l_resource_id
            FROM  jtf_rs_role_relations a,
                  jtf_rs_roles_vl b,
                  jtf_rs_resource_extns_vl c
            WHERE a.role_resource_type = 'RS_INDIVIDUAL'
            AND   a.role_resource_id = c.resource_id
            AND   a.role_id = b.role_id
            AND   b.role_code = 'CREDIT_ANALYST'
            AND   c.category = 'EMPLOYEE'
            AND   c.source_id = l_employee_id
            AND   nvl(a.delete_flag,'N') <> 'Y';


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                    wf_core.context('AR_CMGT_WF_ENGINE','GET_CREDIT_ANALYST',itemtype, itemkey,
                          'Resource Id Not found for User:'||wf_engine.context_text ||' '||'Sqlerror '||sqlerrm);
                    raise;
            WHEN OTHERS THEN
                    wf_core.context('AR_CMGT_WF_ENGINE','GET_CREDIT_ANALYST',itemtype, itemkey,
                          'Sqlerror while getting Resource Id'||sqlerrm);
                    raise;
        END;
        get_employee_details(l_employee_id,l_user_name, l_display_name);

        WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => itemkey,
                                aname    => 'CREDIT_ANALYST_USER_NAME',
                                avalue   => l_user_name);
        WF_ENGINE.setItemAttrNumber(itemType => 'ARCMGTAP',
                                itemKey  => itemkey,
                                aname    => 'CREDIT_ANALYST_ID',
                                avalue   => l_resource_id);
        WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => itemkey,
                                aname    => 'CREDIT_ANALYST_DISPLAY_NAME',
                                avalue   => l_display_name);


/*
         RVIRIYAL: BUG#9300043: START
         This procedure is called from the reassign credit schedular screen
         When the case folder is created with no credit analyst.
         When there is no credit analyst a notification will be sent to the
         credit Manager.Now when the user assigns the credit analyst,
         notification raised will be closed.In the below piece of code we are
         updating the credit analyst along with the who columns.If the function
         mode is Transfer, then there is no need to update the fields as the
         same operation will be done by means of Entity Objects(EO). If the
         update happens at both the levels (EO and at this API),
         FND_RECORD_CHANGED_ERROR will be thrown
*/
        IF funcmode <> 'TRANSFER' THEN
		UPDATE ar_cmgt_credit_requests
		set    credit_analyst_id = l_resource_id,
		       last_update_date = sysdate,
		       last_updated_by = fnd_global.user_id,
		       last_update_login = fnd_global.login_id
		WHERE  credit_request_id = itemkey
		AND    credit_analyst_id IS NULL;

		UPDATE ar_cmgt_case_folders
		set    credit_analyst_id = l_resource_id,
		       last_updated = sysdate,
		       last_update_date = sysdate,
		       last_updated_by = fnd_global.user_id,
		       last_update_login = fnd_global.login_id
		WHERE  credit_request_id = itemkey
		AND    credit_analyst_id IS NULL;
        END IF;

/*RVIRIYAL: BUG#9300043: END*/

        l_failure_function := WF_ENGINE.getItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'FAILURE_FUNCTION');

        IF l_failure_function = 'CREDIT_POLICY'
        THEN

            l_notification_id :=
                    WF_NOTIFICATION.send
                            ( role => wf_engine.context_text,
                              msg_type => 'ARCMGTAP',
                              msg_name => 'MSG_TO_CA_INV_POLICY_SUBMIT',
                              callback => 'WF_ENGINE.CB',
                              context => itemtype||':'||itemkey||':'||to_char(actid));

        ELSIF l_failure_function = 'SCORING_MODEL'
        THEN
            l_notification_id :=
                    WF_NOTIFICATION.send
                            ( role => wf_engine.context_text,
                              msg_type => 'ARCMGTAP',
                              msg_name => 'MSG_CA_NO_SM',
                              callback => 'WF_ENGINE.CB',
                              context => itemtype||':'||itemkey||':'||to_char(actid));
        ELSIF l_failure_function = 'SCORING_CURRENCY'
        THEN
            l_notification_id :=
                    WF_NOTIFICATION.send
                            ( role => wf_engine.context_text,
                              msg_type => 'ARCMGTAP',
                              msg_name => 'MSG_TO_CA_CURRENCY_NOT_MATCH',
                              callback => 'WF_ENGINE.CB',
                              context => itemtype||':'||itemkey||':'||to_char(actid));
        ELSIF l_failure_function = 'MANUAL_ANALYSIS'
        THEN
            l_notification_id :=
                    WF_NOTIFICATION.send
                            ( role => wf_engine.context_text,
                              msg_type => 'ARCMGTAP',
                              msg_name => 'MSG_TO_CA_MANUAL_ANALYSIS',
                              callback => 'WF_ENGINE.CB',
                              context => itemtype||':'||itemkey||':'||to_char(actid));
        ELSIF l_failure_function = 'SKIP_APPROVAL'
        THEN
            l_notification_id :=
                    WF_NOTIFICATION.send
                            ( role => wf_engine.context_text,
                              msg_type => 'ARCMGTAP',
                              msg_name => 'REASG_MSG_TO_CA_SKIP_APPROVAL',
                              callback => 'WF_ENGINE.CB',
                              context => itemtype||':'||itemkey||':'||to_char(actid));
        ELSIF l_failure_function = 'GATHER_DATA_POINTS'
        THEN
            l_notification_id :=
                    WF_NOTIFICATION.send
                            ( role => wf_engine.context_text,
                              msg_type => 'ARCMGTAP',
                              msg_name => 'MSG_TO_CA_NO_CF_CREATED',
                              callback => 'WF_ENGINE.CB',
                              context => itemtype||':'||itemkey||':'||to_char(actid));
        ELSIF l_failure_function = 'GENERATE_RECOMMENDATION'
        THEN
            l_notification_id :=
                    WF_NOTIFICATION.send
                            ( role => wf_engine.context_text,
                              msg_type => 'ARCMGTAP',
                              msg_name => 'MSG_TO_CA_NO_RECO',
                              callback => 'WF_ENGINE.CB',
                              context => itemtype||':'||itemkey||':'||to_char(actid));
        ELSIF l_failure_function = 'VALIDATE_RECO'
        THEN
            l_notification_id :=
                    WF_NOTIFICATION.send
                            ( role => wf_engine.context_text,
                              msg_type => 'ARCMGTAP',
                              msg_name => 'MSG_TO_CA_INVALID_RECO',
                              callback => 'WF_ENGINE.CB',
                              context => itemtype||':'||itemkey||':'||to_char(actid));

	 	ELSIF l_failure_function = 'DUPLICATE_CASE_FOLDER'
        THEN
            l_notification_id :=
                    WF_NOTIFICATION.send
                            ( role => wf_engine.context_text,
                              msg_type => 'ARCMGTAP',
                              msg_name => 'MESSAGE_APPEAL_INITIATED',
                              callback => 'WF_ENGINE.CB',
                              context => itemtype||':'||itemkey||':'||to_char(actid));

        END IF;
    END IF;
END;

PROCEDURE getCAFromRulesEngine(
		p_itemtype	        IN	VARCHAR2,
                p_credit_request_id	IN	number,
		p_credit_analyst_id	OUT NOCOPY	NUMBER ) IS


	l_country				hz_parties.country%type;
	l_state					hz_parties.state%type;
	l_province				hz_parties.province%type;
	l_sic_code				hz_parties.sic_code%type;
	l_postal_code				hz_parties.postal_code%type;
	l_party_name			hz_parties.party_name%type;
	l_employees_total		hz_parties.employees_total%type;
	l_credit_classification	ar_cmgt_credit_requests.credit_classification%type;
	l_amount				ar_cmgt_credit_requests.limit_amount%type;
	l_review_type			ar_cmgt_credit_requests.review_type%type;
	l_profile_class_name	hz_cust_profile_classes.name%type;
	l_currency				ar_cmgt_credit_requests.limit_currency%type;
	l_party_id			hz_parties.party_id%type;

	 /* 7132845 */
        l_parent_request_id  NUMBER;
        l_parent_analyst_id  NUMBER;
        l_credit_request_id  NUMBER;
   /*
     Rule Engine Enhancement:Start
     Cursor to retrive the custom parameters for OCM_CREDIT_ANALYST_ASSGN
   */
   CURSOR get_custom_params IS
    SELECT param_name
		FROM fun_rule_crit_params_b param,
		     fun_rule_objects_vl rule_object
		WHERE rule_object.rule_object_name = 'OCM_CREDIT_ANALYST_ASSGN'
		AND   rule_object.rule_object_id = param.rule_object_id
		AND   param.parameter_type = 'CUSTOM';
		l_custom_param_name VARCHAR2(50);
		l_custom_param_value VARCHAR2(50);

BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       debug('ar_cmgt_wf_engine.getCAfromrulesengine()+');
       debug('   p_credit_request_id = ' || p_credit_request_id);
    END IF;
    /* 7113063 Make sure guarantor CR/CF are assigned to the same
       analyst as the parent CR/CF.  We'll do that by using the
       parent credit request info to get the assignment and then
       pass that to the child.  */

       BEGIN
          SELECT parent.credit_request_id,
                 parent.credit_analyst_id
          INTO   l_parent_request_id,
                 l_parent_analyst_id
          FROM   ar_cmgt_credit_requests parent,
                 ar_cmgt_credit_requests child
          WHERE  child.credit_request_id = p_credit_request_id
          AND    child.parent_credit_request_id = parent.credit_request_id
          AND    child.credit_request_type = 'GUARANTOR';

       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL; /* Not a child request */
       END;

       /* if the parent has a analyst already, use it (quick return) */
       IF l_parent_analyst_id IS NOT NULL
       THEN
         IF pg_wf_debug = 'Y'
         THEN
            debug('  Using parent analyst directly');
            debug('  returning p_analyst_id = ' || l_parent_analyst_id);
            debug('ar_cmgt_wf_engine.getCAfromrulesengine()-');
         END IF;

           p_credit_analyst_id := l_parent_analyst_id;
 	   RETURN;

	END IF;
       /* if the parent exists, but does not have a analyst yet,
          use the parent_request_id (and associated data)
          to determine the analyst.  */
       IF l_parent_request_id IS NULL
       THEN
          /* No parent, use the parameter credit request id */
          IF pg_wf_debug = 'Y'
          THEN
             debug('  Using original request');
          END IF;
          l_credit_request_id := p_credit_request_id;
       ELSE
          /* use the parent credit_request_id instead */
          IF pg_wf_debug = 'Y'
          THEN
             debug('  Using parent request to fetch analyst');
             debug('  parent_credit_request_id = ' || l_parent_request_id);
          END IF;
          l_credit_request_id := l_parent_request_id;
       END IF;

        -- Get All values for parametsrs
	BEGIN
		SELECT p.country,p.state, p.province,p.sic_code,p.party_name,
		       p.employees_total, c.credit_classification,
		       nvl(c.limit_amount,c.trx_amount), c.review_type,
		       nvl(c.limit_currency,c.trx_currency),
		       profclass.name, p.postal_code, p.state, p.party_id
		INTO   l_country, l_state, l_province, l_sic_code,
			   l_party_name, l_employees_total, l_credit_classification,
			   l_amount, l_review_type, l_currency,
			   l_profile_class_name, l_postal_code, l_state, l_party_id
		FROM   ar_cmgt_credit_requests c,
		       hz_parties p,
		       hz_cust_profile_classes profclass,
		       hz_customer_profiles prof
		WHERE  c.credit_request_id = p_credit_request_id
		AND    c.party_id = p.party_id
		AND    p.party_id  = prof.party_id
		AND    c.cust_account_id = decode(prof.cust_account_id,-1,-99,prof.cust_account_id)
		AND    c.site_use_id = nvl(prof.site_use_id,-99)
		AND	   prof.profile_class_id = profclass.profile_class_id;

		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				p_credit_analyst_id := NULL;
				return;
			WHEN OTHERS THEN
				wf_core.context('AR_CMGT_WF_ENGINE','getCAFromRulesEngine',p_itemtype, p_credit_request_id,
                   'Error While getting Rules Engine Parameter Details',sqlerrm);
                raise;


	END;
	-- now call rules engine
    FUN_RULE_PUB.init_parameter_list;
    FUN_RULE_PUB.add_parameter('AMOUNT_REQUESTED',l_amount );
    FUN_RULE_PUB.add_parameter('CREDIT_CLASSIFICATION', l_credit_classification);
    FUN_RULE_PUB.add_parameter('CUSTOMER_PROFILE_CLASS',l_profile_class_name );
    FUN_RULE_PUB.add_parameter('COUNTRY',l_country );
    FUN_RULE_PUB.add_parameter('STATE',l_state );
    FUN_RULE_PUB.add_parameter('PROVINCE',l_province );
    FUN_RULE_PUB.add_parameter('SIC_CODE',l_sic_code );
    FUN_RULE_PUB.add_parameter('CUSTOMER_NAME',l_party_id);
    FUN_RULE_PUB.add_parameter('NUM_EMPLOYEE',l_employees_total );
    FUN_RULE_PUB.add_parameter('REVIEW_TYPE',l_review_type );
    FUN_RULE_PUB.add_parameter('CURRENCY',l_currency );
    FUN_RULE_PUB.add_parameter('POSTAL_CODE',l_postal_code );

    /**
     * RVIRIYAL|START|23-Feb-2010|Modifications for Rules Engine Enhancement.
     * Rules Engine functionality is enhanced by evaluating the
     * rules created using custom parameters.
     * After creating the custom parameters and creating rules with the same
     * user need to set the parameter with the value in Rules Engine,
     * before evaluating the rules. To calculate the values for the
     * custom parameters created by the user, a hook package is provided
     * to the user, in which the logic to derive custom parameter values
     * will be written.
     * Implementation:
     * Rule Object Name for Credit Analyst Assignment is OCM_CREDIT_ANALYST_ASSGN
     * All the custom parameters associated with this Rule Object are retrieved
     * and the values are calculated by invoking the hook procedure for this
     * Rule Object Implementation. Once the custom rule Parameter's value is
     * obtained, parameter and its value are set in the rules engine such that
     * the rules will be evaluated.
   **/
     OPEN get_custom_params;
     LOOP
       FETCH get_custom_params INTO l_custom_param_name;

       AR_CMGT_PARAMS_HOOK_PKG.get_ocm_custom_param_value(
            P_CREDIT_REQUEST_ID=>p_credit_request_id
           ,P_CUSTOM_PARAM_NAME=>l_custom_param_name
           ,P_CUSTOM_PARAM_VALUE=>l_custom_param_value);

       IF pg_wf_debug = 'Y'
       THEN
         debug('Custom Parameter Name: '||l_custom_param_name);
         debug('Custom Parameter Value = ' ||l_custom_param_value );
       END IF;

       FUN_RULE_PUB.add_parameter(l_custom_param_name,l_custom_param_value);

       EXIT WHEN get_custom_params%NOTFOUND;
     END LOOP;
     CLOSE get_custom_params;


     /* RVIRIYAL|END|23-Feb-2010|Modifications for Rules Engine Enhancement**/

    FUN_RULE_PUB.apply_rule('AR','OCM_CREDIT_ANALYST_ASSGN');
	p_credit_analyst_id := FUN_RULE_PUB.get_number;

        IF pg_wf_debug = 'Y'
        THEN
           debug(' returning credit_analyst_id = ' || p_credit_analyst_id);
           debug('ar_cmgt_wf_engine.getCAfromrulesengine()-');
        END IF;

	EXCEPTION
		WHEN OTHERS THEN
			wf_core.context('AR_CMGT_WF_ENGINE','getCAFromRulesEngine',p_itemtype, p_credit_request_id,
                          'Error While calling Rules Engine',sqlerrm);
             raise;
END;

PROCEDURE ASSIGN_CREDIT_ANALYST (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

    l_user_name         VARCHAR2(60);
    l_display_name      VARCHAR2(240);
    l_case_folder_id    ar_cmgt_case_folders.case_folder_id%type;
    l_credit_analyst_id ar_cmgt_credit_requests.credit_analyst_id%type;
    l_employee_id       per_people_f.person_id%type;
    l_dummy             VARCHAR2(1);
BEGIN
    IF funcmode = 'RUN'
    THEN
        l_credit_analyst_id := WF_ENGINE.getItemAttrNumber
                                (itemType => 'ARCMGTAP',
                                itemKey  => itemkey,
                                aname    => 'CREDIT_ANALYST_ID');

        IF l_credit_analyst_id IS NULL
        THEN
        	-- Bug 4414431
        	-- Rules engine uptake
        	getCAFromRulesEngine(
        		p_itemtype				=>  itemtype,
        		p_credit_request_id		=> 	itemkey,
				p_credit_analyst_id		=>  l_credit_analyst_id );

        	IF l_credit_analyst_id IS NULL
        	THEN
            	BEGIN
                	SELECT a.CREDIT_ANALYST_ID
                	INTO   l_credit_analyst_id
                	FROM   hz_customer_profiles a, ar_cmgt_credit_requests b
                	WHERE  b.credit_request_id = itemkey
                	AND    a.party_id = b.party_id
                	AND    a.cust_account_id = decode(b.cust_account_id,-99,-1,b.cust_account_id)
                	AND    nvl(a.site_use_id,-99)  = nvl(b.site_use_id, -99);

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_credit_analyst_id := NULL;
                    WHEN OTHERS THEN
                        wf_core.context('AR_CMGT_WF_ENGINE','ASSIGN_CREDIT_ANALYST',itemtype, itemkey,
                          'Error While getting Credit Analyst Id',sqlerrm);
                       raise;
            	END;
            END IF;
            -- Since we found the credit ananlyst, validate the credit ananlyst
            -- against jtf

            BEGIN
                SELECT 'X'
                INTO   l_dummy
                FROM  jtf_rs_role_relations a,
                      jtf_rs_roles_vl b,
                      jtf_rs_resource_extns_vl c
                WHERE a.role_resource_type = 'RS_INDIVIDUAL'
                AND   a.role_resource_id = c.resource_id
                AND   c.resource_id = l_credit_analyst_id
                AND   a.role_id = b.role_id
                AND   b.role_code = 'CREDIT_ANALYST'
                AND   c.category = 'EMPLOYEE'
                AND   nvl(a.delete_flag,'N') <> 'Y';
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                        l_credit_analyst_id := NULL;
                 WHEN OTHERS THEN
                        wf_core.context('AR_CMGT_WF_ENGINE','ASSIGN_CREDIT_ANALYST',itemtype, itemkey,
                          'Error While validating Credit Analyst Id:'||l_credit_analyst_id,sqlerrm);
                       raise;
            END;

            -- Also check if credit analyst is null
            IF l_credit_analyst_id IS NULL
            THEN
                create_creditManagement_role(itemtype, itemkey);
                resultout := 'COMPLETE:FAILURE';
                return;
            END IF;
            BEGIN
                SELECT source_id
                INTO   l_employee_id
                FROM   jtf_rs_resource_extns_vl
                WHERE  resource_id = l_credit_analyst_id
                AND    category = 'EMPLOYEE';

                EXCEPTION
                    WHEN OTHERS THEN
                        wf_core.context('AR_CMGT_WF_ENGINE','ASSIGN_CREDIT_ANALYST',itemtype, itemkey,
                          'Error While getting Employee Id for Credit Analyst',sqlerrm);
                       raise;
            END;

            get_employee_details(l_employee_id,l_user_name, l_display_name);

            UPDATE ar_cmgt_credit_requests
                SET credit_analyst_id = l_credit_analyst_id,
                    last_update_date = sysdate,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
            WHERE  credit_request_id = itemkey;


            WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => itemkey,
                                aname    => 'CREDIT_ANALYST_USER_NAME',
                                avalue   => l_user_name);
            WF_ENGINE.setItemAttrNumber(itemType => 'ARCMGTAP',
                                itemKey  => itemkey,
                                aname    => 'CREDIT_ANALYST_ID',
                                avalue   => l_credit_analyst_id);
            WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => itemkey,
                                aname    => 'CREDIT_ANALYST_DISPLAY_NAME',
                                avalue   => l_display_name);

       END IF; -- end of credit analyst is null
       -- Stamp CA to case folder
       l_case_folder_id := WF_ENGINE.getItemAttrNumber
                            (itemType => 'ARCMGTAP',
                             itemKey  => itemkey,
                             aname    => 'CASE_FOLDER_ID');
       IF l_case_folder_id IS NOT NULL
       THEN
            update ar_cmgt_case_folders
                set credit_analyst_id = l_credit_analyst_id,
                    last_updated = sysdate,
                    last_update_date = sysdate,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
            WHERE  case_folder_id  = l_case_folder_id;

            -- Also upadate data records with credit_analyst_id
            update ar_cmgt_case_folders
                set credit_analyst_id = l_credit_analyst_id,
                    last_updated = sysdate,
                    last_update_date = sysdate,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
            WHERE  credit_request_id  = itemkey
            AND    type = 'DATA';
       END IF;
       resultout := 'COMPLETE:SUCESS';
    END IF;
END;


/**************************************************
** This procedure will start workflow process
***************************************************/
PROCEDURE start_workflow (
    p_credit_request_id          IN      NUMBER,
    p_application_status         IN      VARCHAR2 default 'SUBMIT') AS

    l_save_threshold            NUMBER;
    l_status                    VARCHAR2(2000);
    l_resultout                 VARCHAR2(2000);
    l_user_name                 VARCHAR2(60);
    l_display_name              VARCHAR2(240);
    l_application_status        varchar2(2000);

BEGIN

    IF pg_wf_debug = 'Y' THEN
     debug('ar_cmgt_wf_engine.start_workflow()+');
     debug('  p_credit_request_id = ' || p_credit_request_id);
     debug('  p_application_status = ' || p_application_status);
    END IF;

    -- The following parameter will kickoff WF in async. mode
    l_save_threshold := WF_ENGINE.threshold;

    WF_ENGINE.threshold := -1;

    IF p_application_status  = 'FINISH'
    THEN
        WF_ENGINE.CreateProcess (itemType => 'ARCMGTAP',
                                 itemKey  => p_credit_request_id,
                                 process  => 'AR_CMGT_APPLICATION_PROCESS');

        WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => p_credit_request_id,
                                aname    => 'CREDIT_REQUEST_ID',
                                avalue   => p_credit_request_id);


        WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => p_credit_request_id,
                                aname    => 'APPLICATION_STATUS',
                                avalue   => p_application_status);

        WF_ENGINE.StartProcess ( itemType => 'ARCMGTAP',
                                 itemKey  => p_credit_request_id);

    ELSIF p_application_status = 'SUBMIT'
    THEN

        BEGIN
            WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                             itemKey  => p_credit_request_id,
                             aname    => 'APPLICATION_STATUS',
                             avalue   => p_application_status);

             /* Try to complete the usual BLOCK activity */
            BEGIN

            WF_ENGINE.CompleteActivity( itemType => 'ARCMGTAP',
                                        itemkey  => p_credit_request_id,
                                        activity => 'BLOCK',
                                        result => NULL);

            EXCEPTION
              WHEN OTHERS THEN
               /* Unable to complete the activity, so try
                  to handle the error with a RETRY */
               WF_ENGINE.HandleErrorAll(itemType => 'ARCMGTAP',
                              itemKey  => p_credit_request_id,
                              activity => NULL,
                              command  => 'RETRY',
                              result   => '',
                              docommit => false);
            END;

        EXCEPTION
            WHEN OTHERS THEN
                WF_ENGINE.CreateProcess (itemType => 'ARCMGTAP',
                                 itemKey  => p_credit_request_id,
                                 process  => 'AR_CMGT_APPLICATION_PROCESS');
                WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => p_credit_request_id,
                                aname    => 'CREDIT_REQUEST_ID',
                                avalue   => p_credit_request_id);

                WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => p_credit_request_id,
                                aname    => 'APPLICATION_STATUS',
                                avalue   => p_application_status);

                WF_ENGINE.StartProcess ( itemType => 'ARCMGTAP',
                                 itemKey  => p_credit_request_id);


        END;


    END IF;



    WF_ENGINE.threshold := l_save_threshold;

    IF pg_wf_debug = 'Y' THEN
      debug('ar_cmgt_wf_engine.start_workflow()-');
    END IF;
END;

PROCEDURE GENERATE_CREDIT_CLASSIFICATION (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

    l_credit_classification         ar_cmgt_credit_requests.credit_classification%type;
    l_party_id                      ar_cmgt_credit_requests.party_id%type;
    l_cust_account_id               ar_cmgt_credit_requests.cust_account_id%type;
    l_site_use_id                   ar_cmgt_credit_requests.site_use_id%type;

    l_sql_statement                 VARCHAR2(2000);

BEGIN
  IF funcmode = 'RUN'
  THEN
    SELECT credit_classification, party_id, cust_account_id, site_use_id
    INTO   l_credit_classification, l_party_id, l_cust_account_id, l_site_use_id
    FROM   ar_cmgt_credit_requests
    WHERE  credit_request_id = itemkey;

    IF l_credit_classification IS NULL
    THEN

        l_credit_classification := AR_CMGT_UTIL.get_credit_classification(p_party_id => l_party_id,
                                                                          p_cust_account_id => l_cust_account_id,
                                                                          p_site_use_id => l_site_use_id);
        UPDATE ar_cmgt_credit_requests
          SET  credit_classification = l_credit_classification
          WHERE credit_request_id = itemkey;
    END IF; -- end of credit classification
    -- Now update the credit classification in wf
    WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'CREDIT_CLASSIFICATION',
                                avalue   =>  l_credit_classification );
  END IF;

  EXCEPTION
    WHEN others THEN
          wf_core.context('AR_CMGT_WF_ENGINE','GENERATE_CREDIT_CLASSIFICATION',itemtype, itemkey,
                            sqlerrm);
          raise;
END;

PROCEDURE UPDATE_CREDIT_REQ_TO_PROCESS (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

BEGIN

    IF funcmode = 'RUN'
    THEN
        UPDATE ar_cmgt_credit_requests
        SET    status = 'IN_PROCESS',
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
        WHERE  credit_request_id = itemkey;

    END IF;

END;

PROCEDURE UPDATE_CREDIT_REQ_TO_SUBMIT (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

BEGIN

    IF funcmode = 'RUN'
    THEN
        UPDATE ar_cmgt_credit_requests
        SET    status = 'SUBMIT',
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
        WHERE  credit_request_id = itemkey;

    END IF;

END;

PROCEDURE UPDATE_CASE_FOLDER_SUBMITTED (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

    l_case_folder_id        ar_cmgt_case_folders.case_folder_id%type;
BEGIN

    IF funcmode = 'RUN'
    THEN

        l_case_folder_id := WF_ENGINE.GetItemAttrNumber
                     (itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'CASE_FOLDER_ID');

        UPDATE ar_cmgt_case_folders
        SET    status = 'SUBMITTED',
               last_updated = sysdate,
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
        WHERE  case_folder_id = l_case_folder_id;

    END IF;

END;


PROCEDURE CHECK_APPLICATION_STATUS (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

l_application_status            VARCHAR2(30);

BEGIN

    IF funcmode = 'RUN'
    THEN
        l_application_status :=
                  WF_ENGINE.GetItemAttrText
                     (itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'APPLICATION_STATUS');


        resultout := 'COMPLETE:'||l_application_status;

    END IF;

EXCEPTION
    WHEN OTHERS
    THEN
        wf_core.context('AR_CMGT_WF_ENGINE','CHECK_APPLICATION_STATUS',itemtype, itemkey,
                            sqlerrm);
        raise;
END;

PROCEDURE CREATE_PARTY_PROFILE (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

    l_party_id                  ar_cmgt_credit_requests.party_id%type;
    l_cust_acct_id              ar_cmgt_credit_requests.cust_account_id%type;
    l_site_use_id               ar_cmgt_credit_requests.site_use_id%type;
    l_cust_account_profile_id   hz_customer_profiles.cust_account_profile_id%type;
    l_return_status VARCHAR2(1);
BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       debug('ar_cmgt_wf_engine.create_party_profile()+');
    END IF;

-- need to check and if not exists then craeet party profile(ARCMHZCB.pls AR_CMGT_HZ_COVER_API)
    IF funcmode = 'RUN'
    THEN
       SELECT party_id, cust_account_id, site_use_id
       INTO   l_party_id, l_cust_acct_id, l_site_use_id
       FROM   ar_cmgt_credit_requests
       WHERE  credit_request_id = itemkey;

       /* 9283064 - Determine if request is party, acct, or site
          level.  Only proceed if it is party-level */

       WF_ENGINE.setItemAttrNumber(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'PARTY_ID',
                                   avalue => l_party_id);

       IF pg_wf_debug = 'Y'
       THEN
          debug('  party_id = ' || l_party_id ||
                '  acct_id = ' || l_cust_acct_id ||
                '  site_id = ' || l_site_use_id);
       END IF;

       IF l_cust_acct_id = -99 AND
          l_site_use_id  = -99
       THEN

          BEGIN
            SELECT cust_account_profile_id
            INTO   l_cust_account_profile_id
            FROM   hz_customer_profiles
            WHERE  party_id = l_party_id
            AND    cust_account_id = -1
            AND    site_use_id IS NULL;

           IF pg_wf_debug = 'Y'
           THEN
              debug('  found:  party profile_id = ' ||
                             l_cust_account_profile_id);
           END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               IF pg_wf_debug = 'Y'
               THEN
                  debug('   not found:  creating party profile');
               END IF;

               ar_cmgt_hz_cover_api.create_party_profile(
                                      p_party_id => l_party_id,
                                      p_return_status => l_return_status);

               /* 7272415 - Error handling for TCA API */
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS
               THEN
                  IF pg_wf_debug = 'Y'
                  THEN
                      debug('   TCA API failed to create party profile');
                  END IF;
                  wf_core.context('AR_CMGT_WF_ENGINE','CREATE_PARTY_PROFILE',
                                     itemtype, itemkey, 'TCA API failure');
                  raise;
               END IF;

            WHEN OTHERS
            THEN
               wf_core.context('AR_CMGT_WF_ENGINE','CREATE_PARTY_PROFILE',
                    itemtype, itemkey,sqlerrm);
               raise;
          END;

        ELSE
           IF pg_wf_debug = 'Y'
           THEN
              debug('   No party-level profile required');
           END IF;

        END IF;


    END IF;

    IF pg_wf_debug = 'Y'
    THEN
       debug('ar_cmgt_wf_engine.create_party_profile()-');
    END IF;
END;

PROCEDURE CHECK_CREDIT_POLICY (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

    l_credit_classification     ar_cmgt_check_lists.credit_classification%TYPE;
    l_review_type               ar_cmgt_check_lists.review_type%TYPE;
    l_check_list_id             ar_cmgt_check_lists.check_list_id%TYPE;
    l_score_model_id            ar_cmgt_scores.score_model_id%TYPE;
    l_currency                  ar_cmgt_credit_requests.limit_currency%TYPE;
    l_amount_requested          ar_cmgt_credit_requests.limit_amount%TYPE;
    l_case_folder_number        ar_cmgt_case_folders.case_folder_number%type;
    l_source_name               ar_cmgt_credit_requests.source_name%type;
    l_classification_meaning    ar_lookups.meaning%type;
    l_review_type_meaning       ar_lookups.meaning%type;
    l_application_number        ar_cmgt_credit_requests.application_number%type;
    l_score_model_already_set   VARCHAR2(1) := 'F';
    l_requestor_id              ar_cmgt_credit_requests.requestor_id%type;
    l_requestor_user_name       fnd_user.user_name%type;
    l_requestor_display_name    per_people_f.full_name%type;
    l_party_id					hz_parties.party_id%type;
    l_cust_account_id			hz_cust_accounts.cust_account_id%type;
    l_party_name				hz_parties.party_name%type;
    l_party_number				hz_parties.party_number%type;
    l_account_number			hz_cust_accounts.account_number%type;
    l_application_date			ar_cmgt_credit_requests.application_date%type;
    l_source_column1			ar_cmgt_credit_requests.source_column1%type;
	l_source_column2			ar_cmgt_credit_requests.source_column2%type;
	l_source_column3			ar_cmgt_credit_requests.source_column3%type;
	l_notes						ar_cmgt_credit_requests.notes%type;
	l_credit_request_type		ar_cmgt_credit_requests.credit_request_type%type;
	l_requestor_type			ar_cmgt_credit_requests.requestor_type%type;

BEGIN
    IF funcmode = 'RUN'
    THEN

        -- based on credit request id get credit classification and review type
        -- to find valid check list and build case folder table.
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'CREDIT_POLICY');
        BEGIN
            SELECT req.credit_classification, req.review_type,
                   nvl(req.limit_currency, trx_currency),
                   nvl(nvl(req.limit_amount,req.trx_amount),0),
                   req.case_folder_number, req.score_model_id, req.source_name,
                   req.application_number,
                   lkp1.meaning classification_meaning,
                   lkp2.meaning review_type_meaning,
                   requestor_id,
                   application_date,
                   req.party_id,
                   cust_account_id,
                   source_column1,
                   source_column2,
                   source_column3,
                   party.party_name,
                   party.party_number,
                   req.notes,
                   req.credit_request_type,
                   nvl(req.requestor_type, 'EMPLOYEE')
            INTO   l_credit_classification, l_review_type, l_currency,
                   l_amount_requested, l_case_folder_number, l_score_model_id,
                   l_source_name, l_application_number,
                   l_classification_meaning,
                   l_review_type_meaning,
                   l_requestor_id,
                   l_application_date,
                   l_party_id,
                   l_cust_account_id,
                   l_source_column1,
                   l_source_column2,
                   l_source_column3,
                   l_party_name,
                   l_party_number,
                   l_notes,
                   l_credit_request_type,
                   l_requestor_type
            FROM   ar_cmgt_credit_requests req,
                   ar_lookups lkp1,
                   ar_lookups lkp2,
                   hz_parties party
            WHERE  req.credit_request_id = itemkey
            AND    req.party_id = party.party_id
            AND    lkp1.lookup_type = 'AR_CMGT_CREDIT_CLASSIFICATION'
            AND    lkp1.lookup_code = req.credit_classification
            AND    lkp2.lookup_type = 'AR_CMGT_REVIEW_TYPE'
            AND    lkp2.lookup_code = req.review_type;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                SELECT req.credit_classification, req.review_type, req.application_number,
                       req.score_model_id,
                       application_date,
                   	   req.party_id,
                   	   cust_account_id,
                   	   source_column1,
                   	   source_column2,
                   	   source_column3,
                   	   party.party_name,
                   	   party.party_number,
                   	   req.notes,
                   	   req.requestor_id,
                   	   req.source_name,
                   	   req.case_folder_number,
					   nvl(req.limit_currency, trx_currency),
                   	   nvl(nvl(req.limit_amount,req.trx_amount),0),
                   	   req.credit_request_type,
                   	   nvl(req.requestor_type, 'EMPLOYEE')
                INTO   l_credit_classification, l_review_type, l_application_number,
                       l_score_model_id,
                    	l_application_date,
                   		l_party_id,
                   		l_cust_account_id,
                   		l_source_column1,
                   		l_source_column2,
                   		l_source_column3,
                   		l_party_name,
                   	    l_party_number,
                   	    l_notes,
                   	    l_requestor_id,
                   	    l_source_name,
                   	    l_case_folder_number,
                   	    l_currency,
                   	    l_amount_requested,
                   	    l_credit_request_type,
                   	    l_requestor_type
                FROM   ar_cmgt_credit_requests req,
                	   hz_parties party
                WHERE  credit_request_id = itemkey
				AND    req.party_id = party.party_id;


                resultout := 'COMPLETE:NOTFOUND';
                --return;
            WHEN OTHERS THEN
                wf_core.context ('AR_CMGT_WF_ENGINE','CHECK_CREDIT_POLICY',itemtype,itemkey,
                                 sqlerrm);
                raise;
        END;

        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'CREDIT_CLASSIFICATION',
                                avalue   =>  l_credit_classification );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REVIEW_TYPE',
                                avalue   =>  l_review_type );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'CURRENCY',
                                avalue   =>  l_currency );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'SOURCE_NAME',
                                avalue   =>  l_source_name );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'APPLICATION_NUMBER',
                                avalue   =>  l_application_number );
        WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTED_CREDIT_LIMIT',
                                avalue   =>  l_amount_requested );
        WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_PERSON_ID',
                                avalue   =>  l_requestor_id );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'SOURCE_COL1',
                                avalue   =>  l_source_column1 );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'SOURCE_COL2',
                                avalue   =>  l_source_column2 );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'SOURCE_COL3',
                                avalue   =>  l_source_column3 );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'PARTY_NAME',
                                avalue   =>  l_party_name );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'PARTY_NUMBER',
                                avalue   =>  l_party_number );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'APPL_NOTES',
                                avalue   =>  l_notes );
        WF_ENGINE.SetItemAttrDate(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'APPLICATION_DATE',
                                avalue   =>  l_application_date );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'CREDIT_REQUEST_TYPE',
                                avalue   =>  l_credit_request_type );

        IF l_requestor_type = 'EMPLOYEE'
        THEN
			get_employee_details(
                p_employee_id        => l_requestor_id,
                p_user_name          => l_requestor_user_name,
                p_display_name       => l_requestor_display_name);

        	WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_USER_NAME',
                                avalue   =>  l_requestor_user_name );
        	WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_DISPLAY_NAME',
                                avalue   =>  l_requestor_display_name );
		ELSE
			-- get user id
			BEGIN
					SELECT user_name
					INTO   l_requestor_user_name
					FROM   fnd_user
					WHERE  user_id = l_requestor_id;

					WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_USER_NAME',
                                avalue   =>  l_requestor_user_name );

					WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_DISPLAY_NAME',
                                avalue   =>  l_requestor_user_name );
					EXCEPTION
						WHEN NO_DATA_FOUND THEN
							wf_core.context ('AR_CMGT_WF_ENGINE','CHECK_CREDIT_POLICY',itemtype,itemkey,
                                 'FND User Not Found'|| sqlerrm);
                			raise;
						WHEN OTHERS THEN
							wf_core.context ('AR_CMGT_WF_ENGINE','CHECK_CREDIT_POLICY',itemtype,itemkey,
                                 'Other Error '|| sqlerrm);
                			raise;
			END;
        END IF;
        IF l_case_folder_number IS NOT NULL
        THEN

            WF_ENGINE.SetItemAttrNumber
                                (itemtype  =>  itemtype,
                                itemkey  =>    itemkey,
                                aname    =>    'CASE_FOLDER_NUMBER',
                                avalue   =>    l_case_folder_number );
        END IF;
        IF l_score_model_id IS NOT NULL
        THEN
            l_score_model_already_set := 'T';
            WF_ENGINE.setItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'SCORE_MODEL_ID',
                                    avalue    => l_score_model_id);
        END IF;
        -- check if the application is on accounts level and set the account Number
        IF l_cust_account_id <> -99
        THEN
        	BEGIN
        		SELECT ACCOUNT_NUMBER
        		INTO   l_account_number
        		FROM   hz_cust_accounts
				WHERE  cust_account_id = l_cust_account_id;
        	EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_account_number := null;
				WHEN OTHERS THEN
                	wf_core.context ('AR_CMGT_WF_ENGINE','CHECK_CREDIT_POLICY',itemtype,itemkey,
                                 'Getting Account Details SqlError: '|| sqlerrm);
                	raise;

        	END;
        	WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'ACCOUNT_NUMBER',
                                avalue   =>  l_account_number );
        END IF;
        IF resultout = 'COMPLETE:NOTFOUND'
        THEN
        	return;
        END IF;
        BEGIN
            SELECT check_list_id, score_model_id
            INTO   l_check_list_id, l_score_model_id
            FROM   ar_cmgt_check_lists
            WHERE  submit_flag = 'Y'
            AND    credit_classification = l_credit_classification
            AND    review_type = l_review_type
	    AND    SYSDATE BETWEEN start_date and nvl(end_date,SYSDATE);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- in case of no_data_found Assign Credit Analyst and send notification
                -- to CA.
                wf_core.context ('AR_CMGT_WF_ENGINE','CHECK_CREDIT_POLICY',itemtype,itemkey,
                                 'No Check List found for the combination');
                resultout := 'COMPLETE:NOTFOUND';
                return;
            WHEN OTHERS THEN
                wf_core.context ('AR_CMGT_WF_ENGINE','CHECK_CREDIT_POLICY',itemtype,itemkey,
                                 sqlerrm);
                raise;

        END;
        IF     l_score_model_id IS NOT NULL
           AND l_score_model_already_set = 'F'
        THEN
            WF_ENGINE.setItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'SCORE_MODEL_ID',
                                    avalue    => l_score_model_id);

        ELSIF l_score_model_id IS NULL
        THEN
            -- in case of null set to -99
            WF_ENGINE.setItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'SCORE_MODEL_ID',
                                    avalue    => -99);
        END IF;

        IF l_check_list_id IS NULL
        THEN
            WF_ENGINE.setItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'CHECK_LIST_ID',
                                    avalue    => -99);
            resultout := 'COMPLETE:NOTFOUND';
        ELSE
            WF_ENGINE.setItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'CHECK_LIST_ID',
                                    avalue    => l_check_list_id);
        	--Update credit request table with checklistid
        	UPDATE ar_cmgt_credit_requests
        	set    check_list_id = l_check_list_id
        	WHERE  credit_request_id = itemkey;

            resultout := 'COMPLETE:FOUND';
        END IF;


    END IF;
END;

PROCEDURE SET_ROUTING_STATUS (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

    l_manual_analysis_flag      VARCHAR2(1);

    -- Fix for Bug 8792071 - Start
	  l_trx_credit_limit			ar_cmgt_cf_recommends.recommendation_value2%TYPE;
	  l_cred_limit				ar_cmgt_cf_recommends.recommendation_value2%TYPE;
	  l_amount_requested          ar_cmgt_credit_requests.limit_amount%TYPE;

	  CURSOR c_get_cf_reco_info1 IS
	  SELECT recommendation_value2
	  FROM ar_cmgt_cf_recommends
	  WHERE credit_recommendation = 'CREDIT_LIMIT'
	  AND credit_request_id = itemkey;

	  CURSOR c_get_cf_reco_info2 IS
	  SELECT recommendation_value2
	  FROM ar_cmgt_cf_recommends
	  WHERE credit_recommendation = 'TXN_CREDIT_LIMIT'
	  AND credit_request_id = itemkey;
    -- Fix for Bug 8792071 - End

BEGIN
    IF funcmode = 'RUN'
    THEN
        l_manual_analysis_flag :=
                    WF_ENGINE.GetItemAttrText
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'MANUAL_ANALYSIS_FLAG');
        IF ( l_manual_analysis_flag = 'Y' )
        THEN
            resultout := 'COMPLETE:APPROVAL_ROUTE';

          -- Fix for Bug 8792071 - Start
          -- Check if Credit Limit' or 'Transaction Credit Limit' recommendations exists
          -- If yes then the amount_requested is assigned to this value
          OPEN c_get_cf_reco_info1;
          FETCH c_get_cf_reco_info1 INTO l_cred_limit;
          CLOSE c_get_cf_reco_info1;

          OPEN c_get_cf_reco_info2;
          FETCH c_get_cf_reco_info2 INTO l_trx_credit_limit;
          CLOSE c_get_cf_reco_info2;

          IF (l_cred_limit IS NOT NULL) THEN
            l_amount_requested := l_cred_limit;
          ELSIF (l_trx_credit_limit IS NOT NULL) THEN
            l_amount_requested := l_trx_credit_limit;
          END IF;

          IF (l_amount_requested IS NOT NULL) THEN
            WF_ENGINE.SetItemAttrNumber(itemtype =>  itemtype,
                                        itemkey  =>  itemkey,
                                	      aname    =>  'REQUESTED_CREDIT_LIMIT',
                                	      avalue   =>  l_amount_requested );
          END IF;
          -- Fix for Bug 8792071 - End

        ELSIF ( l_manual_analysis_flag = 'H' )
        THEN
            resultout := 'COMPLETE:HOLD_ROUTE';
        ELSE
            resultout := 'COMPLETE:INITIAL_ROUTE';
        END IF;

    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            wf_core.context('AR_CMGT_WF_ENGINE','SET_ROUTING_STATUS',itemtype, itemkey,
                            sqlerrm);
            raise;
END;


PROCEDURE CHECK_SCORING_MODEL (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS


    l_score_model_id        ar_cmgt_scores.score_model_id%TYPE;
    l_score_model_id_1      ar_cmgt_scores.score_model_id%TYPE;
    l_trx_amount            ar_cmgt_credit_requests.TRX_AMOUNT%TYPE;


BEGIN
    IF funcmode = 'RUN'
    THEN

        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'SCORING_MODEL');

        l_score_model_id :=
                WF_ENGINE.getItemAttrText(itemtype  =>  itemtype,
                                          itemkey  =>  itemkey,
                                          aname    =>  'SCORE_MODEL_ID');
       /*
          Bug# 9338716: RVIRIYAL: START
	  If there exists no scoring model for a credit request then
	  a notification is sent to the credit analyst. In the notification
	  transaction amount is not being displayed.Created a new attribute
	  TRX_AMOUNT and included in the message. As part of this change
	  transaction amount is being populated
       */

	SELECT trx_amount
	INTO   l_trx_amount
	FROM ar_cmgt_credit_requests
	WHERE credit_request_id = itemkey;

	WF_ENGINE.setItemAttrNumber
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'TRX_AMOUNT',
                         avalue    => l_trx_amount);

          /*Bug# 9338716: RVIRIYAL: END*/

	IF l_score_model_id = -99
        THEN
            resultout := 'COMPLETE:NOTFOUND';
        ELSE
            -- check whether the score is valid or not
            BEGIN
                SELECT score_model_id
                INTO   l_score_model_id_1
                FROM   ar_cmgt_scores
                WHERE  score_model_id = l_score_model_id
                AND    submit_flag = 'Y'
                AND    TRUNC(sysdate) between TRUNC(start_date) and TRUNC(nvl(end_date,SYSDATE));

                resultout := 'COMPLETE:FOUND';
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    resultout := 'COMPLETE:NOTFOUND';
                    return;
            END;
        END IF;
    END IF;
END;

PROCEDURE CHECK_SCORING_CURRENCY (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

    l_limit_currency            ar_cmgt_credit_requests.limit_currency%type;
    l_score_currency            ar_cmgt_scores.currency%type;
    l_score_model_id            ar_cmgt_scores.score_model_id%type;
BEGIN

    -- First get the requested currency and score_model_id
    IF funcmode = 'RUN'
    THEN
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'SCORING_CURRENCY');
        l_score_model_id :=  WF_ENGINE.getItemAttrNumber
                            (itemtype  =>  itemtype,
                             itemkey  =>  itemkey,
                             aname    =>  'SCORE_MODEL_ID');

        l_limit_currency :=  WF_ENGINE.getItemAttrText
                            (itemtype  =>  itemtype,
                             itemkey  =>  itemkey,
                             aname    =>  'LIMIT_CURRENCY');

        BEGIN
/* bug4527823: Added trunc function while comparing dates */
            SELECT currency
            INTO   l_score_currency
            FROM   ar_cmgt_scores
            WHERE  score_model_id = l_score_model_id
            and    submit_flag = 'Y'
            and    TRUNC(nvl(end_date, SYSDATE)) >= TRUNC(sysdate)
            and    ((currency = l_limit_currency) OR (nvl(skip_currency_test_flag, 'N') = 'Y')); -- Added for bug 8600040

            WF_ENGINE.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'SCORE_CURRENCY',
                                    avalue    => l_score_currency);
            resultout := 'COMPLETE:SUCESS';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    resultout := 'COMPLETE:FAILURE';
                WHEN OTHERS THEN
                    raise;
                    resultout := 'COMPLETE:FAILURE';
                    wf_core.context('AR_CMGT_WF_ENGINE','CHECK_SCORING_CURRENCY',itemtype, itemkey,
                            sqlerrm);
        END;

    END IF;

END;



PROCEDURE UNDO_CASE_FOLDER (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

l_case_folder_id            NUMBER;
BEGIN

    IF funcmode = 'RUN'
    THEN
        l_case_folder_id :=  WF_ENGINE.getItemAttrText
                        (itemtype  =>  itemtype,
                         itemkey  =>  itemkey,
                         aname    =>  'CASE_FOLDER_ID');
        delete ar_cmgt_case_folders
            WHERE case_folder_id = case_folder_id;
        delete ar_cmgt_cf_dtls
            WHERE case_folder_id = case_folder_id;
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN
        wf_core.context('AR_CMGT_WF_ENGINE','UNDO_CASE_FOLDER',itemtype, itemkey,
                            sqlerrm);
        raise;
END;


PROCEDURE GATHER_DATA_POINTS (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2) IS

    l_credit_classification ar_cmgt_check_lists.credit_classification%TYPE;
    l_review_type           ar_cmgt_check_lists.review_type%TYPE;
    l_check_list_id         ar_cmgt_check_lists.check_list_id%TYPE;
    l_party_id              ar_cmgt_credit_requests.party_id%type;
    l_cust_account_id       ar_cmgt_credit_requests.cust_account_id%type;
    l_cust_acct_site_id     ar_cmgt_credit_requests.cust_acct_site_id%type;
    l_request_id            ar_cmgt_credit_requests.credit_request_id%type;
    l_trx_currency          ar_cmgt_credit_requests.trx_currency%type;
    l_limit_currency        ar_cmgt_credit_requests.limit_currency%type;
    l_case_folder_number    ar_cmgt_case_folders.case_folder_number%type;
    l_org_id                NUMBER ;
    l_score_model_id        NUMBER;
    l_credit_request_id     NUMBER;
    l_case_folder_id        NUMBER;
    l_resultout             VARCHAR2(200);
    BUILD_FAILURE           EXCEPTION;
    l_error_message         VARCHAR2(2000);
    l_case_folder_date		ar_cmgt_case_folders.last_updated%type;

BEGIN
    IF funcmode = 'RUN'
    THEN
        -- get all the relevant information to generate case folder.
        l_credit_request_id := itemkey;
        BEGIN
            SELECT  credit_classification, review_type,
                    cust_account_id, party_id, site_use_id, nvl(limit_currency,trx_currency),
                    source_org_id, case_folder_number
            INTO    l_credit_classification, l_review_type, l_cust_account_id,
                    l_party_id, l_cust_acct_site_id, l_trx_currency, l_org_id,
                    l_case_folder_number
            FROM    ar_cmgt_credit_requests
            WHERE   credit_request_id = itemkey;
        EXCEPTION
            WHEN OTHERS THEN
               wf_core.context ('AR_CMGT_WF_ENGINE','GATHER_DATA_POINTS',itemtype,itemkey,
                                 'Error while getting records from AR_CMGT_CREDIT_REQUESTS',
                                 'Sql Error: '||sqlerrm);
                raise;
        END;
        l_check_list_id := WF_ENGINE.getItemAttrNumber
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'CHECK_LIST_ID');
        l_score_model_id := WF_ENGINE.getItemAttrNumber
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'SCORE_MODEL_ID');

        l_case_folder_number := WF_ENGINE.getItemAttrText
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'CASE_FOLDER_NUMBER');


  	    ar_cmgt_data_points_pkg.gather_data_points
                            (p_party_id             =>  l_party_id,
                             p_cust_account_id      =>  l_cust_account_id,
                             p_cust_acct_site_id    =>  l_cust_acct_site_id,
                             p_trx_currency         =>  l_trx_currency,
                             p_org_id               =>  l_org_id,
                             p_check_list_id        =>  l_check_list_id,
                             p_credit_request_id    =>  l_credit_request_id,
                             p_score_model_id       =>  l_score_model_id,
                             p_credit_classification => l_credit_classification,
                             p_review_type           => l_review_type,
                             p_case_folder_number   =>  l_case_folder_number,
                             p_mode                 =>  'CREATE',
                             p_limit_currency       =>  l_limit_currency,
                             p_case_folder_id       =>  l_case_folder_id,
                             p_error_msg            =>  l_error_message,
                             p_resultout            =>  l_resultout);

        -- this is the error due to some setup data missing
        IF  l_resultout = 2
        THEN
            WF_ENGINE.setItemAttrText
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'FAILURE_MESSAGE',
                         avalue    => l_error_message);
            WF_ENGINE.setItemAttrText
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'FAILURE_FUNCTION',
                         avalue    => 'GATHER_DATA_POINTS');
            resultout := 'COMPLETE:FAILURE';
            return;
        END IF;
        IF l_resultout <> 0
        THEN
            wf_core.context ('AR_CMGT_WF_ENGINE','GATHER_DATA_POINTS',itemtype,itemkey,
                                 'Unable to Generate Case Folder',l_error_message);
            raise BUILD_FAILURE;
        END IF;
        WF_ENGINE.setItemAttrNumber
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'CASE_FOLDER_ID',
                         avalue    => l_case_folder_id);
        WF_ENGINE.setItemAttrText
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'LIMIT_CURRENCY',
                         avalue    => l_limit_currency);
		-- Get case folder details
		BEGIN
			SELECT case_folder_number, last_updated
			INTO   l_case_folder_number, l_case_folder_date
			FROM   ar_cmgt_case_folders
			WHERE  case_folder_id = l_case_folder_id;

			WF_ENGINE.setItemAttrText
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'CASE_FOLDER_NUMBER',
                         avalue    => l_case_folder_number);
        	WF_ENGINE.setItemAttrDate
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'CASE_FOLDER_DATE',
                         avalue    => l_case_folder_date);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_case_folder_number := null;
					l_case_folder_date   := null;
				WHEN OTHERS THEN
					wf_core.context ('AR_CMGT_WF_ENGINE','GATHER_DATA_POINTS',itemtype,itemkey,
                                 'Unable to Get Case Folder Details, SqlError : '||sqlerrm);
		END;
        resultout := 'COMPLETE:SUCESS';

    END IF;

    EXCEPTION
        WHEN BUILD_FAILURE THEN
            raise;
END;

procedure CALCULATE_SCORE(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_case_folder_id    ar_cmgt_case_folders.case_folder_id%TYPE;
    l_check_list_id     ar_cmgt_check_lists.check_list_id%TYPE;
    l_score             NUMBER;
    l_resultout         VARCHAR2(1);
    l_debug_msg         VARCHAR2(2000);
    l_error_msg         VARCHAR2(2000);


BEGIN
  IF funcmode = 'RUN'
  THEN
    l_debug_msg := 'Calculate Score ';
    l_case_folder_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CASE_FOLDER_ID');
    l_check_list_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CHECK_LIST_ID');
    WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'MANUAL_ANALYSIS');


    AR_CMGT_SCORING_ENGINE.GENERATE_SCORE(
                        p_case_folder_id => l_case_folder_id,
                        p_score => l_score,
                        p_error_msg => l_error_msg,
                        p_resultout => l_resultout);


    IF l_resultout = 0
    THEN
        WF_ENGINE.SetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'SCORE',
                                    avalue    => l_score);
         resultout := 'COMPLETE:SUCESS';
    ELSE
         resultout := 'COMPLETE:FAILURE';
    END IF;
  END IF;
  EXCEPTION
        WHEN OTHERS THEN
            wf_core.context('AR_CMGT_WF_ENGINE','CALCULATE_SCORE',itemtype,
                      itemkey, l_debug_msg, l_error_msg);
            raise;
END;

procedure CHECK_AUTO_RULES(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_score_model_id        ar_cmgt_scores.score_model_id%TYPE;
    l_auto_rules_id         ar_cmgt_auto_rules.auto_rules_id%type;
    l_score_model_id_1      ar_cmgt_scores.score_model_id%TYPE;

BEGIN
  IF funcmode = 'RUN'
  THEN

    -- first check whether there are any manual data items exist
    -- if exists then automation is not possible and route to manual analysis

    l_score_model_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SCORE_MODEL_ID');

    WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'MANUAL_ANALYSIS');

    -- first check whether score model is valid for this date or not.
    BEGIN
        SELECT score_model_id
        INTO   l_score_model_id_1
        FROM   ar_cmgt_scores
        WHERE  score_model_id = l_score_model_id
        AND    submit_flag = 'Y'
        AND    TRUNC(sysdate) between TRUNC(start_date) and TRUNC(nvl(end_date,SYSDATE));

        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                resultout := 'COMPLETE:NOTEXIST';
                return;
    END;
    BEGIN
        SELECT auto_rules_id
        INTO   l_auto_rules_id
        FROM   ar_cmgt_auto_rules
        WHERE  score_model_id = l_score_model_id
        AND    submit_flag = 'Y'
        AND    TRUNC(sysdate) between TRUNC(start_date) and TRUNC(nvl(end_date,SYSDATE));

        WF_ENGINE.SetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AUTO_RULES_ID',
                                    avalue    => l_auto_rules_id);
        resultout := 'COMPLETE:EXIST';

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            resultout := 'COMPLETE:NOTEXIST';
        WHEN OTHERS THEN
            wf_core.context('AR_CMGT_WF_ENGINE','CHECK_AUTO_RULES',itemtype,
                      itemkey, sqlerrm);
            raise;
    END;
  END IF;

END;

procedure OVERRIDE_CHECKLIST(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_score                 NUMBER;
    l_auto_rules_id         NUMBER;
    l_override_checklist    ar_cmgt_auto_rule_dtls.override_checklist_flag%type;
    l_skip_approval         ar_cmgt_auto_rule_dtls.skip_approval_flag%type;
    l_currency              ar_cmgt_credit_requests.limit_currency%TYPE;
BEGIN
  IF funcmode = 'RUN'
  THEN

    l_auto_rules_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'AUTO_RULES_ID');

    l_score := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SCORE');
    l_currency := WF_ENGINE.GetItemAttrText
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CURRENCY');


    BEGIN
        SELECT  override_checklist_flag, skip_approval_flag
        INTO   l_override_checklist, l_skip_approval
        FROM   ar_cmgt_auto_rule_dtls
        WHERE  auto_rules_id = l_auto_rules_id
        AND    l_score between credit_score_low and credit_score_high
        AND    currency = l_currency;


        WF_ENGINE.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'SKIP_APPROVAL',
                                    avalue    => l_skip_approval);
        resultout := 'COMPLETE:'||l_override_checklist;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            resultout := 'COMPLETE:N';
            WF_ENGINE.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'SKIP_APPROVAL',
                                    avalue    => 'N');
        WHEN OTHERS THEN
            wf_core.context('AR_CMGT_WF_ENGINE','OVERRIDE_CHECKLIST',itemtype,
                      itemkey, sqlerrm);
            raise;
    END;
  END IF;

END;


procedure CHECK_REQUIRED_DATA_POINTS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_check_list_id                 NUMBER;
    l_case_folder_id                NUMBER;
    l_credit_request_id             NUMBER;
    l_errmsg                        VARCHAR2(2000);
    l_resultout                     VARCHAR2(2000);

    BUILD_FAILURE                   EXCEPTION;

BEGIN
  IF funcmode = 'RUN'
  THEN

    l_credit_request_id := itemkey;

    WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'MANUAL_ANALYSIS');

    l_check_list_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CHECK_LIST_ID');

    l_case_folder_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CASE_FOLDER_ID');

    validate_required_data_points(
                l_credit_request_id,
                l_case_folder_id,
                l_check_list_id,
                l_errmsg,
                l_resultout);
    -- l_resultout will have 3 values
    --  0 = Sucess
    --  1 = fatal error
    --  2 = Required data points missing

    IF  l_resultout = 0
    THEN
         resultout := 'COMPLETE:SUCESS';
    ELSIF  l_resultout = 2
    THEN
         resultout := 'COMPLETE:FAILURE';
    ELSIF  l_resultout = 1
    THEN
            wf_core.context('AR_CMGT_WF_ENGINE','CHECK_REQUIRED_DATA_POINTS',itemtype,
                      itemkey, l_errmsg);
            raise BUILD_FAILURE;
    END IF;

  END IF;

  EXCEPTION
    WHEN BUILD_FAILURE THEN
        raise;
END;

procedure CHECK_SCORING_DATA_POINTS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_score_model_id            NUMBER;
    l_case_folder_id            NUMBER;
    l_data_point_id             NUMBER;
    l_data_point_value          ar_cmgt_cf_dtls.data_point_value%type;
    l_data_point_type           VARCHAR2(255);
    l_null_zero_flag            VARCHAR2(1);
    l_success_flg               VARCHAR2(1);
    l_data_point_code           ar_cmgt_data_points_b.data_point_code%type;

    CURSOR dp_id_collec IS
    	select distinct  data_point_id
    	from ar_cmgt_score_dtls
    	where score_model_id= l_score_model_id;
BEGIN
    IF funcmode = 'RUN'
    THEN
       WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'CHECK_SCORING_DATA_POINTS');
        l_score_model_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SCORE_MODEL_ID');
        l_case_folder_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CASE_FOLDER_ID');

     -- initialize the sucess flag as this flag value will only
     -- change in case the value of null zero flag is 'null'
     -- and data point type is numeric.

	  l_success_flg := 'Y';

      --get the null zero flag

     BEGIN
            SELECT nvl(null_zero_flag,'N')
            INTO   l_null_zero_flag
            FROM   ar_cmgt_scores
            WHERE  score_model_id = l_score_model_id;

        EXCEPTION
            WHEN OTHERS THEN
                 wf_core.context('AR_CMGT_WF_ENGINE','CHECK_SCORING_DATA_POINTS, Scoring Model Not Found '||
                        'Score Model Id : '||l_score_model_id ,itemtype,
                      itemkey, sqlerrm);
                    raise;
        END;

	--get the data point data type for each data point.

	FOR dp_id_collec_rec IN dp_id_collec
	LOOP

         BEGIN
            SELECT RETURN_DATA_TYPE, data_point_code
            INTO   l_data_point_type, l_data_point_code
            FROM   AR_CMGT_SCORABLE_DATA_POINTS_V
            WHERE  DATA_POINT_ID = dp_id_collec_rec.data_point_id;

            -- come out of the loop if scoring model contains External data points
            IF l_data_point_code = 'OCM_EXTERNAL_SCORE'
            THEN
                resultout := 'COMPLETE:FAILURE';
	    		return;
            END IF;
		EXCEPTION
        	WHEN OTHERS THEN
	           wf_core.context('AR_CMGT_WF_ENGINE','CHECK_SCORING_DATA_POINTS, Data Point Details Not Available '||
                                     'for Data Point Id : '||dp_id_collec_rec.data_point_id ,itemtype,
                      itemkey, sqlerrm);
                raise;
        END;


        IF l_null_zero_flag = 'N'
   			OR ( l_null_zero_flag = 'Y'
   			AND l_data_point_type <> 'N')
    	THEN
            	-- if there are null values in data_point_value then
	    		-- scoring is not allowed.
	    		BEGIN

	    			SELECT  case1.data_point_value, case1.data_point_id
            		INTO    l_data_point_value, l_data_point_id
            		FROM    ar_cmgt_score_dtls score,
                    		ar_cmgt_cf_dtls case1
            		WHERE   score.score_model_id = l_score_model_id
            		AND     case1.case_folder_id = l_case_folder_id
            		AND     score.data_point_id  = case1.data_point_id
            		AND     score.data_point_id = dp_id_collec_rec.data_point_id
            		AND     case1.data_point_value IS NULL;

	    			--if a data point value is null and null zero flag is also 'N'
            		resultout := 'COMPLETE:FAILURE';
	    			return;
            	EXCEPTION
                	WHEN NO_DATA_FOUND THEN
                        resultout := 'COMPLETE:SUCESS';
                	WHEN TOO_MANY_ROWS THEN
                    	resultout := 'COMPLETE:FAILURE';
		   				 return;
               		WHEN OTHERS THEN
                    		wf_core.context('AR_CMGT_WF_ENGINE','CHECK_SCORING_DATA_POINTS',itemtype,
                      		itemkey, sqlerrm);
                    		raise;
            	END;
       	ELSIF l_null_zero_flag = 'Y' AND
	     	  l_data_point_type = 'N'
       	THEN
              resultout := 'COMPLETE:SUCESS';
        END IF;
    END LOOP;

   END IF;
END;


procedure SKIP_APPROVAL(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_skip_approval         VARCHAR2(1);

    -- Fix for Bug 8792071 - Start
	l_trx_credit_limit			ar_cmgt_cf_recommends.recommendation_value2%TYPE;
	l_cred_limit				ar_cmgt_cf_recommends.recommendation_value2%TYPE;
	l_amount_requested          ar_cmgt_credit_requests.limit_amount%TYPE;

	CURSOR c_get_cf_reco_info1 IS
	SELECT recommendation_value2
	FROM ar_cmgt_cf_recommends
	WHERE credit_recommendation = 'CREDIT_LIMIT'
	AND credit_request_id = itemkey;

	CURSOR c_get_cf_reco_info2 IS
	SELECT recommendation_value2
	FROM ar_cmgt_cf_recommends
	WHERE credit_recommendation = 'TXN_CREDIT_LIMIT'
	AND credit_request_id = itemkey;
    -- Fix for Bug 8792071 - End

BEGIN
    l_skip_approval := WF_ENGINE.getItemAttrText
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'SKIP_APPROVAL');
    WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'SKIP_APPROVAL');
    IF l_skip_approval = 'Y'
    THEN
        resultout := 'COMPLETE:Y';

        -- Fix for Bug 8792071 - Start
        -- Check if Credit Limit' or 'Transaction Credit Limit' recommendations exists
        -- If yes then the amount_requested is assigned to this value
        OPEN c_get_cf_reco_info1;
        FETCH c_get_cf_reco_info1 INTO l_cred_limit;
        CLOSE c_get_cf_reco_info1;

        OPEN c_get_cf_reco_info2;
        FETCH c_get_cf_reco_info2 INTO l_trx_credit_limit;
        CLOSE c_get_cf_reco_info2;

        IF (l_cred_limit IS NOT NULL) THEN
          l_amount_requested := l_cred_limit;
        ELSIF (l_trx_credit_limit IS NOT NULL) THEN
          l_amount_requested := l_trx_credit_limit;
        END IF;

        IF (l_amount_requested IS NOT NULL) THEN
          WF_ENGINE.SetItemAttrNumber(itemtype =>  itemtype,
                                      itemkey  =>  itemkey,
                                	    aname    =>  'REQUESTED_CREDIT_LIMIT',
                                	    avalue   =>  l_amount_requested );
        END IF;
        -- Fix for Bug 8792071 - End

    ELSE
        resultout := 'COMPLETE:N';
    END IF;
END;

procedure MARK_MANUAL_ANALYSIS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS
BEGIN
    IF funcmode = 'RUN'
    THEN
        -- Depending on the value of the flag recommendation will be implemented.
        -- recommendation route can be reached either by automation or manual.
        -- In case we reach recommendation via manual analysis then we will implement
        -- whatever user defined in case folder.

        WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MANUAL_ANALYSIS_FLAG',
                                  avalue   => 'Y');
    END IF;
END;
procedure UPDATE_RECOMMENDATION
        ( p_party_id                IN      NUMBER,
          p_cust_account_id         IN      NUMBER,
          p_site_use_id             IN      NUMBER default null,
          p_credit_recommendation   IN      VARCHAR2,
          p_reco_value1             IN      VARCHAR2,
          p_reco_value2             IN      VARCHAR2) IS

    l_sql_statement                 VARCHAR2(2000);

BEGIN

            IF p_credit_recommendation = 'CLASSIFICATION'
            THEN
                IF p_site_use_id IS NULL
                THEN
                    l_sql_statement :=
                        ' UPDATE hz_customer_profiles ' ||
                        ' set credit_classification = :1 ,'||
                        ' last_update_date = sysdate ,'||
                        ' last_updated_by = fnd_global.user_id, '||
                        ' last_update_login = fnd_global.login_id '||
                        ' where party_id = :2 '||
                        ' and cust_account_id = :3 '||
                        ' and site_use_id IS NULL' ;
                    EXECUTE IMMEDIATE l_sql_statement using
                            p_reco_value1,
                            p_party_id,
                            p_cust_account_id;
                ELSIF p_site_use_id IS NOT NULL
                THEN
                     l_sql_statement :=
                        ' UPDATE hz_customer_profiles ' ||
                        ' set credit_classification = :1, '||
                        ' last_update_date = sysdate ,'||
                        ' last_updated_by = fnd_global.user_id, '||
                        ' last_update_login = fnd_global.login_id '||
                        ' where party_id = :2 '||
                        ' and cust_account_id = :3 '||
                        ' and site_use_id = :4 ';
                    EXECUTE IMMEDIATE l_sql_statement using
                            p_reco_value1,
                            p_party_id,
                            p_cust_account_id,
                            p_site_use_id;
                END IF;
            ELSIF p_credit_recommendation = 'TXN_CREDIT_LIMIT'
            THEN
                IF p_site_use_id IS NULL
                THEN
                    UPDATE  hz_cust_profile_amts
                        set trx_credit_limit = p_reco_value2,
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE   cust_account_profile_id = (
                                    select cust_account_profile_id
                                    from hz_customer_profiles
                                    WHERE  party_id = p_party_id
                                    AND    cust_account_id = p_cust_account_id
                                    AND    site_use_id IS NULL )
                    AND      currency_code = p_reco_value1;
                ELSIF p_site_use_id IS NOT NULL
                THEN
                    UPDATE  hz_cust_profile_amts
                        set trx_credit_limit = p_reco_value2,
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE   cust_account_profile_id = (
                                    select cust_account_profile_id
                                    from hz_customer_profiles
                                    WHERE  party_id = p_party_id
                                    AND    cust_account_id = p_cust_account_id
                                    AND    site_use_id = p_site_use_id )
                    AND      currency_code = p_reco_value1;
                END IF;
            ELSIF p_credit_recommendation = 'CREDIT_LIMIT'
            THEN
                IF p_site_use_id IS NULL
                THEN
                    UPDATE  hz_cust_profile_amts
                        set overall_credit_limit = p_reco_value2,
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE   cust_account_profile_id = (
                                    select cust_account_profile_id
                                    from hz_customer_profiles
                                    WHERE  party_id = p_party_id
                                    AND    cust_account_id = p_cust_account_id
                                    AND    site_use_id IS NULL )
                    AND      currency_code = p_reco_value1;
                ELSIF p_site_use_id IS NOT NULL
                THEN
                    UPDATE  hz_cust_profile_amts
                        set overall_credit_limit = p_reco_value2,
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE   cust_account_profile_id = (
                                    select cust_account_profile_id
                                    from hz_customer_profiles
                                    WHERE  party_id = p_party_id
                                    AND    cust_account_id = p_cust_account_id
                                    AND    site_use_id = p_site_use_id )
                    AND      currency_code = p_reco_value1;
                END IF;
            ELSIF p_credit_recommendation = 'CUST_HOLD'
            THEN
                IF p_site_use_id IS NULL
                THEN
                    UPDATE  hz_customer_profiles
                        set credit_hold = 'Y',
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE party_id = p_party_id
                      AND cust_account_id = p_cust_account_id
                      AND site_use_id IS NULL;
                ELSIF p_site_use_id IS NOT NULL
                THEN
                    UPDATE  hz_customer_profiles
                        set credit_hold = 'Y',
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE party_id = p_party_id
                      AND cust_account_id = p_cust_account_id
                      AND site_use_id = p_site_use_id;
                END IF;

            ELSIF p_credit_recommendation = 'REMOVE_CUST_HOLD'
            THEN
                IF p_site_use_id IS NULL
                THEN
                    UPDATE  hz_customer_profiles
                        set credit_hold = 'N',
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE party_id = p_party_id
                      AND cust_account_id = p_cust_account_id
                      AND site_use_id IS NULL;
                ELSIF p_site_use_id IS NOT NULL
                THEN
                    UPDATE  hz_customer_profiles
                        set credit_hold = 'N',
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE party_id = p_party_id
                      AND cust_account_id = p_cust_account_id
                      AND site_use_id = p_site_use_id;
                END IF;
            ELSIF p_credit_recommendation = 'PERCENT_CREDIT_LIMIT'
            THEN
                IF p_site_use_id IS NULL
                THEN
                    UPDATE  hz_cust_profile_amts
                        set overall_credit_limit = (overall_credit_limit +
                                    ( overall_credit_limit * p_reco_value2/100)),
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE   cust_account_profile_id = (
                                    select cust_account_profile_id
                                    from hz_customer_profiles
                                    WHERE  party_id = p_party_id
                                    AND    cust_account_id = p_cust_account_id
                                    AND    site_use_id IS NULL )
                    AND      currency_code = p_reco_value1;
                ELSIF p_site_use_id IS NOT NULL
                THEN
                    UPDATE  hz_cust_profile_amts
                        set overall_credit_limit = (overall_credit_limit +
                                    ( overall_credit_limit * p_reco_value2/100)),
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE   cust_account_profile_id = (
                                    select cust_account_profile_id
                                    from hz_customer_profiles
                                    WHERE  party_id = p_party_id
                                    AND    cust_account_id = p_cust_account_id
                                    AND    site_use_id = p_site_use_id )
                    AND      currency_code = p_reco_value1;
                END IF;
            ELSIF p_credit_recommendation = 'PERCENT_TXN_CREDIT_LIMIT'
            THEN
                IF p_site_use_id IS NULL
                THEN
                    UPDATE  hz_cust_profile_amts
                        set trx_credit_limit = (trx_credit_limit +
                                    ( trx_credit_limit * p_reco_value2/100)),
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE   cust_account_profile_id = (
                                    select cust_account_profile_id
                                    from hz_customer_profiles
                                    WHERE  party_id = p_party_id
                                    AND    cust_account_id = p_cust_account_id
                                    AND    site_use_id IS NULL )
                    AND      currency_code = p_reco_value1;
                ELSIF p_site_use_id IS NOT NULL
                THEN
                    UPDATE  hz_cust_profile_amts
                        set trx_credit_limit = (trx_credit_limit +
                                    ( trx_credit_limit * p_reco_value2/100)),
                            last_update_date = sysdate,
                            last_updated_by = fnd_global.user_id,
                            last_update_login = fnd_global.login_id
                    WHERE   cust_account_profile_id = (
                                    select cust_account_profile_id
                                    from hz_customer_profiles
                                    WHERE  party_id = p_party_id
                                    AND    cust_account_id = p_cust_account_id
                                    AND    site_use_id = p_site_use_id )
                    AND      currency_code = p_reco_value1;
                END IF;
            END IF;
END;


procedure GENERATE_RECOMMENDATION(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    insert_failure                  EXCEPTION;
    l_auto_rules_id                 NUMBER;
    l_score                         NUMBER;
    l_credit_limit                  NUMBER := 0;
    l_case_folder_id                NUMBER;
    l_auto_reco_exist               VARCHAR2(1) := 'N';
    l_errmsg                        VARCHAR2(2000);
    l_resultout                     VARCHAR2(1);


    l_currency_code                 ar_cmgt_credit_requests.limit_currency%type;
    l_credit_type                   ar_cmgt_credit_requests.credit_type%type;
    l_credit_request_type			ar_cmgt_credit_requests.credit_request_type%type;
    l_exposure                      NUMBER;
    l_risk_factor                   NUMBER;


    CURSOR c_auto_reco IS
        SELECT a.credit_recommendation, a.recommendation_value1,
               a.recommendation_value2
        FROM   ar_cmgt_auto_recommends a, ar_cmgt_auto_rule_dtls b
        WHERE  a.auto_rule_details_id = b.auto_rule_details_id
        AND    l_score between b.credit_score_low and b.credit_score_high
        AND    a.credit_type = l_credit_type
        AND    b.auto_rules_id = l_auto_rules_id;
BEGIN
    IF funcmode = 'RUN'
    THEN
        -- get credit type from credit requests
        SELECT CREDIT_TYPE, credit_request_type
        INTO   l_credit_type, l_credit_request_type
        FROM   ar_cmgt_credit_requests
        WHERE  credit_request_id = itemkey;

        -- in case of Guarantor no reco. will be generated
        IF l_credit_request_type = 'GUARANTOR'
        THEN
        	resultout := 'COMPLETE:SUCESS';
        	return;
        END IF;

        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'GENERATE_RECOMMENDATION');

        l_case_folder_id := WF_ENGINE.GetItemAttrNumber
                        (itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'CASE_FOLDER_ID');

        l_score := WF_ENGINE.GetItemAttrNumber
                        (itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'SCORE');

        l_auto_rules_id := WF_ENGINE.GetItemAttrNumber
                        (itemtype => itemtype,
                         itemkey  => itemkey,
                         aname    => 'AUTO_RULES_ID');

        -- Now check if any auto recommendation exists
        FOR c_auto_rec IN c_auto_reco
        LOOP
            l_auto_reco_exist := 'Y';
            AR_CMGT_CONTROLS.populate_recommendation(
                        p_case_folder_id        => l_case_folder_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_score                 => l_score,
                        p_recommended_credit_limit  => l_credit_limit,
                        p_credit_review_date    => sysdate,
                        p_credit_recommendation => c_auto_rec.credit_recommendation,
                        p_recommendation_value1 => c_auto_rec.recommendation_value1,
                        p_recommendation_value2 => trunc(c_auto_rec.recommendation_value2),
                        p_status                => 'O',
                        p_credit_type           => l_credit_type,
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

            IF l_resultout <> 0
            THEN
               raise insert_failure;
            END IF;
        END LOOP;

        IF l_auto_reco_exist = 'Y'
        THEN
            resultout := 'COMPLETE:SUCESS';
        ELSE
            resultout := 'COMPLETE:FAILURE';
        END IF;


    END IF;
    EXCEPTION
        WHEN insert_failure THEN
                wf_core.context('AR_CMGT_WF_ENGINE','GENERATE_RECOMMENDATION',itemtype,
                            itemkey,
                            'Error while inserting into ar_cmgt_cf_recommends',
                            sqlerrm);
                raise;
END;



procedure APPROVAL_PROCESS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_approver_rec_out      ame_util.approverRecord;
    l_admin_approver_rec    ame_util.approverRecord;
    l_case_folder_id number;
    l_approver_id number;
    l_approver_user_name varchar2(100);
    l_approver_display_name varchar2(100);

    l_employee_id number;


BEGIN
    IF funcmode = 'RUN'
    THEN
    -- dbms_session.set_sql_trace(true);


     l_case_folder_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'CASE_FOLDER_ID');


     ame_api.getNextApprover( applicationIdIn => 222,
                              transactionIdIn => l_case_folder_id,
                              transactionTypeIn => 'ARCMGTAP',
                              nextApproverOut => l_approver_rec_out);

    l_approver_id := l_approver_rec_out.person_id;

    ame_api.getadminapprover(adminapproverout => l_admin_approver_rec);
  IF l_approver_rec_out.person_id = l_admin_approver_rec.person_id
  THEN

    wf_core.context('AR_CMGT_WF_ENGINE','APPROVAL_PROCESS',itemtype,
                            itemkey, 'Approver is Admin User', null);
    --raise;
  END IF;


    if ( l_approver_id is not null ) -- next approver exist
    then


          get_employee_details(l_approver_id,
                              l_approver_user_name,
                              l_approver_display_name);

          IF wf_directory.UserActive(l_approver_user_name)
          THEN
                WF_ENGINE.setItemAttrNumber(itemType => itemtype,
                                            itemKey  => itemkey,
                                            aname    => 'APPROVER_ID',
                                            avalue   => l_approver_id);

                WF_ENGINE.setItemAttrText(itemType => itemtype,
                                          itemKey  => itemkey,
                                          aname    => 'APPROVER_USER_NAME',
                                          avalue   => l_approver_user_name);
                WF_ENGINE.setItemAttrText(itemType => itemtype,
                                      itemKey  => itemkey,
                                      aname    => 'APPROVER_DISPLAY_NAME',
                                      avalue   => l_approver_display_name);
                resultout := 'COMPLETE:EXIST';
          ELSE

                resultout := 'COMPLETE:NOTEXIST';
          END IF;

    else -- next approver doesnot exist
        resultout := 'COMPLETE:NOTEXIST';
    end if;
 END IF;
END;

procedure UPDATE_AME_APPROVE(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_case_folder_id number;
    l_approver_id  number;

    -- Fix for Bug 8792071 - Start
	  l_trx_credit_limit			ar_cmgt_cf_recommends.recommendation_value2%TYPE;
	  l_cred_limit				ar_cmgt_cf_recommends.recommendation_value2%TYPE;
	  l_amount_requested          ar_cmgt_credit_requests.limit_amount%TYPE;

	  CURSOR c_get_cf_reco_info1 IS
	  SELECT recommendation_value2
	  FROM ar_cmgt_cf_recommends
	  WHERE credit_recommendation = 'CREDIT_LIMIT'
	  AND credit_request_id = itemkey;

	  CURSOR c_get_cf_reco_info2 IS
	  SELECT recommendation_value2
	  FROM ar_cmgt_cf_recommends
	  WHERE credit_recommendation = 'TXN_CREDIT_LIMIT'
	  AND credit_request_id = itemkey;
    -- Fix for Bug 8792071 - End

BEGIN
    IF funcmode = 'RUN'
    THEN

       WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => itemkey,
                                aname    => 'CREDIT_REQUEST_ID',
                                avalue   => itemkey);
       l_case_folder_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'CASE_FOLDER_ID');
       l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'APPROVER_ID');

       ame_api.updateApprovalStatus2(applicationIdIn => 222,
                                     transactionIdIn => l_case_folder_id,
                                     approvalStatusIn => AME_UTIL.approvedStatus,
                                     approverPersonIdIn => l_approver_id,
                                     transactionTypeIn => 'ARCMGTAP');

        resultout := 'COMPLETE:';


        -- Fix for Bug 8792071 - Start
        -- Check if Credit Limit' or 'Transaction Credit Limit' recommendations exists
        -- If yes then the amount_requested is assigned to this value
        OPEN c_get_cf_reco_info1;
        FETCH c_get_cf_reco_info1 INTO l_cred_limit;
        CLOSE c_get_cf_reco_info1;

        OPEN c_get_cf_reco_info2;
        FETCH c_get_cf_reco_info2 INTO l_trx_credit_limit;
        CLOSE c_get_cf_reco_info2;

        IF (l_cred_limit IS NOT NULL) THEN
          l_amount_requested := l_cred_limit;
        ELSIF (l_trx_credit_limit IS NOT NULL) THEN
          l_amount_requested := l_trx_credit_limit;
        END IF;

        IF (l_amount_requested IS NOT NULL) THEN
          WF_ENGINE.SetItemAttrNumber(itemtype =>  itemtype,
                                      itemkey  =>  itemkey,
                                	    aname    =>  'REQUESTED_CREDIT_LIMIT',
                                	    avalue   =>  l_amount_requested );
        END IF;
        -- Fix for Bug 8792071 - End
    END IF;
END;

procedure UPDATE_AME_REJECT(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_case_folder_id number;
    l_approver_id  number;
BEGIN
    IF funcmode = 'RUN'
    THEN
       l_case_folder_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'CASE_FOLDER_ID');
       l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'APPROVER_ID');
       ame_api.updateApprovalStatus2(applicationIdIn => 222,
                                     transactionIdIn => l_case_folder_id,
                                     approvalStatusIn => AME_UTIL.rejectStatus,
                                     approverPersonIdIn => l_approver_id,
                                     transactionTypeIn => 'ARCMGTAP');
      Update ar_cmgt_cf_recommends
            set status = 'R',
                last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
        WHERE case_folder_id = l_case_folder_id;

      Update ar_cmgt_case_folders
            set status = 'CLOSED',
                last_updated = sysdate,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
      WHERE  case_folder_id = l_case_folder_id;

      Update ar_cmgt_credit_requests
            set status = 'PROCESSED',
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
        WHERE  credit_request_id = itemkey;

    END IF;
END;

PROCEDURE IMPLEMENT_RECOMMENDATION(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_case_folder_id            ar_cmgt_case_folders.case_folder_id%type;
    l_credit_type               ar_cmgt_credit_requests.credit_type%type;
    l_party_id                  ar_cmgt_credit_requests.party_id%type;
    l_cust_account_id           ar_cmgt_credit_requests.cust_account_id%type;
    l_site_use_id               ar_cmgt_credit_requests.site_use_id%type;
    l_error_msg                 VARCHAR2(2000);
    l_return_status             VARCHAR2(1);
    HOLD_ERROR                  EXCEPTION;
    l_reco_id                   ar_cmgt_cf_recommends.RECOMMENDATION_ID%TYPE;
    l_dayz                      ar_cmgt_cf_recommends.RECOMMENDATION_VALUE1%TYPE;
    no_data_found               EXCEPTION;
    l_last_revw_date             hz_customer_profiles.LAST_CREDIT_REVIEW_DATE%TYPE;
    l_entity_code               VARCHAR2(1);
	l_entity_id                 NUMBER;
	l_msg_count					NUMBER;

    CURSOR c_reco IS
        SELECT credit_recommendation, recommendation_value1,
               recommendation_value2
        FROM   ar_cmgt_cf_recommends
        WHERE  case_folder_id = l_case_folder_id
        AND    credit_type    = l_credit_type;
BEGIN
    IF funcmode = 'RUN'
    THEN

         BEGIN
            SELECT party_id, decode(cust_account_id,-99,-1,cust_account_id),
                   decode(site_use_id,-99,null,site_use_id), credit_type
            INTO   l_party_id, l_cust_account_id, l_site_use_id, l_credit_type
            FROM   ar_cmgt_credit_requests
            WHERE  credit_request_id = itemkey;

        END;

      l_case_folder_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CASE_FOLDER_ID');

        FOR c_reco_rec IN c_reco
        LOOP


            IF  c_reco_rec.credit_recommendation = 'CLASSIFICATION' OR
                c_reco_rec.credit_recommendation = 'TXN_CREDIT_LIMIT' OR
                c_reco_rec.credit_recommendation = 'CREDIT_LIMIT' OR
                c_reco_rec.credit_recommendation = 'CUST_HOLD' OR
                c_reco_rec.credit_recommendation = 'REMOVE_CUST_HOLD' OR
                c_reco_rec.credit_recommendation = 'PERCENT_CREDIT_LIMIT' OR
                c_reco_rec.credit_recommendation = 'PERCENT_TXN_CREDIT_LIMIT'
            THEN
                    UPDATE_RECOMMENDATION
                    ( p_party_id                => l_party_id,
                      p_cust_account_id         => l_cust_account_id,
                      p_site_use_id             => l_site_use_id,
                      p_credit_recommendation   => c_reco_rec.credit_recommendation,
                      p_reco_value1             => c_reco_rec.recommendation_value1,
                      p_reco_value2             => trunc(c_reco_rec.recommendation_value2));

                    IF l_site_use_id IS NOT NULL THEN
					  l_entity_code := 'S';
					ELSIF  l_cust_account_id IS NOT NULL THEN
                       l_entity_code := 'C';
                    END IF;

					IF l_entity_code = 'S' THEN
					    l_entity_id := l_site_use_id;
					ELSIF l_entity_code = 'C' THEN
                         l_entity_id :=	l_cust_account_id;
                    END IF;

                    -- When customer is placed on hold put all the
                    -- orders on hold
                    IF c_reco_rec.credit_recommendation = 'CUST_HOLD'
                    THEN
					    /*
						   Commenting this call as the org wont be set while calling the Apply/Release
						   order API.Replaced this API with Process Holds API -Bug#8652193
	     					AR_CMGT_UTIL.OM_CUST_APPLY_HOLD (
	                            p_party_id          =>  l_party_id,
	                            p_cust_account_id   =>  l_cust_account_id,
	                            p_site_use_id       =>  l_site_use_id,
	                            p_error_msg         =>  l_error_msg,
							    p_return_status		=>  l_return_status );
						*/

                       	OE_Holds_PUB.Process_Holds (
				          p_api_version         => 1.0,
				          p_init_msg_list       => FND_API.G_FALSE,
				          p_hold_entity_code    => l_entity_code,
				          p_hold_entity_id      => l_entity_id,
				          p_hold_id             => 1,
				          p_release_reason_code => 'AR_AUTOMATIC',
				          p_action              => 'APPLY',
				          x_return_status       => l_return_status,
				          x_msg_count           => l_msg_count,
				          x_msg_data            => l_error_msg);

				        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                        THEN
                            wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_RECOMMENDATION',itemtype,
                                itemkey,
                                'Error while applying Customer Hold for Party : '||l_party_id||' Cust Account Id '||
									l_cust_account_id||' Site Use Id '|| l_site_use_id ||' '|| l_error_msg,
                            	sqlerrm);
                	       raise hold_error;
                        END IF;
                    ELSIF c_reco_rec.credit_recommendation = 'REMOVE_CUST_HOLD'
                    THEN
                        -- When customer is placed on hold put all the
                        -- orders on hold
                        /*
						Commenting this call as the org wont be set while calling the Apply/Release
						order API.Replaced this API with Process Holds API -Bug#8652193
						AR_CMGT_UTIL.OM_CUST_RELEASE_HOLD (
                            p_party_id          =>  l_party_id,
                            p_cust_account_id   =>  l_cust_account_id,
                            p_site_use_id       =>  l_site_use_id,
                            p_error_msg         =>  l_error_msg,
						    p_return_status		=>  l_return_status );
						*/
						OE_Holds_PUB.Process_Holds (
				          p_api_version         => 1.0,
				          p_init_msg_list       => FND_API.G_FALSE,
				          p_hold_entity_code    => l_entity_code,
				          p_hold_entity_id      => l_entity_id,
				          p_hold_id             => 1,
				          p_release_reason_code => 'AR_AUTOMATIC',
				          p_action              => 'RELEASE',
				          x_return_status       => l_return_status,
				          x_msg_count           => l_msg_count,
				          x_msg_data            => l_error_msg);

				        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                        THEN
                            wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_RECOMMENDATION',itemtype,
                                itemkey,
                                'Error while applying Removing Hold for Party : '||l_party_id||' Cust Account Id '||
									l_cust_account_id||' Site Use Id '|| l_site_use_id ||' '|| l_error_msg,
                            	sqlerrm);
                	        raise  hold_error;
                        END IF;
                    END IF;
	    ELSIF c_reco_rec.credit_recommendation = 'AUTHORIZE_APPEAL'
	    THEN

	        --get the number of days as authorized by CA

	        BEGIN

                SELECT recommendation_value1,RECOMMENDATION_ID
                INTO l_dayz,l_reco_id
                FROM ar_cmgt_cf_recommends
                WHERE CASE_FOLDER_ID = l_case_folder_id
                AND credit_recommendation = 'AUTHORIZE_APPEAL';



	       EXCEPTION
                      WHEN NO_DATA_FOUND
                      THEN
                       wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'No data found in recommendations for Appeal',
                            sqlerrm);
                      raise;

                     WHEN OTHERS
		     THEN
                      wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'Error accessing system options',
                            sqlerrm);
                      raise;

                 END;


	 --update number of days in ar_cmgt_cf_recommends

               UPDATE AR_CMGT_CF_RECOMMENDS
               SET RECOMMENDATION_VALUE2 = fnd_date.DATE_TO_CANONICAL(trunc(sysdate) + to_number(trunc(l_dayz))),
	       last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
               WHERE RECOMMENDATION_ID = l_reco_id;

               if (sql%notfound)
               THEN
               raise no_data_found;
               END IF;

	    --the recommendations is 'Change Review Cycle'

            ELSIF c_reco_rec.credit_recommendation = 'CHANGE_REVIEW_CYCLE'
	    THEN

	        --get the last credit review date for updation if site use id is null.

		 IF l_site_use_id IS NULL
		 THEN

		   BEGIN

		   SELECT LAST_CREDIT_REVIEW_DATE
		   INTO l_last_revw_date
		   FROM hz_customer_profiles
		   WHERE  party_id = l_party_id
		   AND cust_account_id =  l_cust_account_id
		   AND  site_use_id IS NULL;

		   EXCEPTION
                      WHEN NO_DATA_FOUND
                      THEN
                       wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'No data found in customer profiles',
                            sqlerrm);
                      raise;

                   WHEN OTHERS
		     THEN
                      wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'Error accessing customer profiles',
                            sqlerrm);
                      raise;

                   END;


                     IF  l_last_revw_date IS NOT NULL
		     THEN
         	     BEGIN

		     UPDATE hz_customer_profiles
		     SET REVIEW_CYCLE = c_reco_rec.recommendation_value1,
                     NEXT_CREDIT_REVIEW_DATE = DECODE(c_reco_rec.recommendation_value1,
                                                   'YEARLY',    (l_last_revw_date + 365),
                                                   'HALF_YEARLY',  (l_last_revw_date + 180),
                                                   'QUARTERLY', (l_last_revw_date + 90),
                                                    'MONTHLY',   (l_last_revw_date + 30),
                                                    'WEEKLY',   (l_last_revw_date + 7),
                                                                 l_last_revw_date + 1),
                 last_update_date = sysdate,				-- Fix for Bug 9617807
                 last_updated_by = fnd_global.user_id,
                 last_update_login = fnd_global.login_id
             WHERE  party_id = l_party_id
		     AND cust_account_id =  l_cust_account_id
		     AND  site_use_id IS NULL;

		     EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                     wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                                    itemkey,'No data found in profile for updation',
                                    sqlerrm);
                     raise;

                     WHEN OTHERS
		     THEN
                      wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'Error accessing customer profiles',
                            sqlerrm);
                     raise;

                     END;
			ELSE
              BEGIN
			     UPDATE hz_customer_profiles
		         SET REVIEW_CYCLE = c_reco_rec.recommendation_value1,
				     LAST_CREDIT_REVIEW_DATE = sysdate,
                     NEXT_CREDIT_REVIEW_DATE = DECODE(c_reco_rec.recommendation_value1,
                                                   'YEARLY',    (sysdate + 365),
                                                   'HALF_YEARLY',  (sysdate + 180),
                                                   'QUARTERLY', (sysdate + 90),
                                                    'MONTHLY',   (sysdate + 30),
                                                    'WEEKLY',   (sysdate + 7),
                                                                 sysdate + 1),
                     last_update_date = sysdate,				-- Fix for Bug 9617807
                     last_updated_by = fnd_global.user_id,
                     last_update_login = fnd_global.login_id
                 WHERE  party_id = l_party_id
		         AND cust_account_id =  l_cust_account_id
		         AND  site_use_id IS NULL;

		     EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                     wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                                    itemkey,'No data found in profile for updation',
                                    sqlerrm);
                     raise;

                     WHEN OTHERS
		     THEN
                      wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'Error accessing customer profiles',
                            sqlerrm);
                     raise;
              END;
		     END IF;



		     ELSIF l_site_use_id IS NOT NULL
		     THEN

		     --get last review date for site use id not null.
                     BEGIN

		     SELECT LAST_CREDIT_REVIEW_DATE
		     INTO l_last_revw_date
		     FROM hz_customer_profiles
		     WHERE  party_id = l_party_id
		     AND cust_account_id =  l_cust_account_id
		     AND  site_use_id = l_site_use_id;



		     EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                       wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'No data found in cust profile for update',
                            sqlerrm);
                     raise;

                     WHEN OTHERS
		     THEN
                     wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'Error accessing customer profile',
                            sqlerrm);
                     raise;

                     END;

                     IF  l_last_revw_date IS NOT NULL
		     THEN
         	      BEGIN

		      UPDATE hz_customer_profiles
			  SET REVIEW_CYCLE = c_reco_rec.recommendation_value1,
                          NEXT_CREDIT_REVIEW_DATE = DECODE(review_cycle,
                                                   'YEARLY',    (l_last_revw_date + 365),
                                                   'HALF_YEARLY',  (l_last_revw_date + 180),
                                                   'QUARTERLY', (l_last_revw_date + 90),
                                                    'MONTHLY',   (l_last_revw_date + 30),
                                                    'WEEKLY',   (l_last_revw_date + 7),
                                                                 l_last_revw_date + 1),
                 last_update_date = sysdate,				-- Fix for Bug 9617807
                 last_updated_by = fnd_global.user_id,
                 last_update_login = fnd_global.login_id
              WHERE  party_id = l_party_id
		      AND cust_account_id =  l_cust_account_id
		      AND  site_use_id IS NOT NULL;

			 EXCEPTION
                      WHEN NO_DATA_FOUND
                      THEN
                       wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'No data found in profile for updation',
                            sqlerrm);
                      raise;

                     WHEN OTHERS
		     THEN
                      wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'Error accessing customer profiles',
                            sqlerrm);
                      raise;

                     END;

			ELSE
			  --BUG#7371458 : Implementing the recommendation when last_credit_review_date is null
                BEGIN
                  UPDATE hz_customer_profiles
		          SET REVIEW_CYCLE = c_reco_rec.recommendation_value1,
			          LAST_CREDIT_REVIEW_DATE = sysdate,
                      NEXT_CREDIT_REVIEW_DATE = DECODE(c_reco_rec.recommendation_value1,
                                                   'YEARLY',    (sysdate + 365),
                                                   'HALF_YEARLY',  (sysdate + 180),
                                                   'QUARTERLY', (sysdate + 90),
                                                    'MONTHLY',   (sysdate + 30),
                                                    'WEEKLY',   (sysdate + 7),
                                                                 sysdate + 1),
                     last_update_date = sysdate,				-- Fix for Bug 9617807
                     last_updated_by = fnd_global.user_id,
                     last_update_login = fnd_global.login_id
                 WHERE  party_id = l_party_id
		         AND cust_account_id =  l_cust_account_id
		         AND  site_use_id = l_site_use_id;
		       EXCEPTION

                      WHEN NO_DATA_FOUND THEN
                       wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'No data found in profile for updation at site level',
                            sqlerrm);
                      raise;

                     WHEN OTHERS  THEN
                      wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'Error accessing customer profiles at site level',
                            sqlerrm);
                      raise;

                END;

		     END IF;

	    END IF;

	    END IF;

        END LOOP;

        Update ar_cmgt_cf_recommends
            set status = 'I',
                last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
        WHERE case_folder_id = l_case_folder_id;

        Update ar_cmgt_case_folders
            set status = 'CLOSED',
                last_updated = sysdate,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
        WHERE  case_folder_id = l_case_folder_id;

        Update ar_cmgt_credit_requests
            set status = 'PROCESSED',
                last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
        WHERE  credit_request_id = itemkey;
    END IF;
    EXCEPTION
        WHEN HOLD_ERROR THEN
            raise;
END;

PROCEDURE POST_IMPLEMENT_PROCESS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_case_folder_id            ar_cmgt_case_folders.case_folder_id%type;
    l_party_id                  ar_cmgt_credit_requests.party_id%type;
    l_cust_account_id           ar_cmgt_credit_requests.cust_account_id%type;
    l_site_use_id               ar_cmgt_credit_requests.site_use_id%type;
    l_credit_limit              NUMBER := 0;
    l_exposure                  NUMBER;
    l_risk_factor               NUMBER;
    l_limit_currency            ar_cmgt_case_folders.limit_currency%type;
    l_errmsg                    VARCHAR2(2000);
    l_resultout                 VARCHAR2(1);
    l_parent_credit_request_id	NUMBER;

    -- Fix for Bug 8660531 - Start
	l_trx_credit_limit			ar_cmgt_cf_recommends.recommendation_value2%TYPE;
	l_cred_limit				ar_cmgt_cf_recommends.recommendation_value2%TYPE;
	l_amount_requested          ar_cmgt_credit_requests.limit_amount%TYPE;

	CURSOR c_get_cf_reco_info1 IS
	SELECT recommendation_value2
	FROM ar_cmgt_cf_recommends
	WHERE credit_recommendation = 'CREDIT_LIMIT'
	AND credit_request_id = itemkey;

	CURSOR c_get_cf_reco_info2 IS
	SELECT recommendation_value2
	FROM ar_cmgt_cf_recommends
	WHERE credit_recommendation = 'TXN_CREDIT_LIMIT'
	AND credit_request_id = itemkey;
    -- Fix for Bug 8660531 - End

BEGIN
    IF  funcmode = 'RUN'
    THEN

        -- Fix for Bug 8660531 - Start
        -- Check if Credit Limit' or 'Transaction Credit Limit' recommendations exists
        -- If yes then the amount_requested is assigned to this value
        OPEN c_get_cf_reco_info1;
        FETCH c_get_cf_reco_info1 INTO l_cred_limit;
        CLOSE c_get_cf_reco_info1;

        OPEN c_get_cf_reco_info2;
        FETCH c_get_cf_reco_info2 INTO l_trx_credit_limit;
        CLOSE c_get_cf_reco_info2;

        IF (l_cred_limit IS NOT NULL) THEN
          l_amount_requested := l_cred_limit;
        ELSIF (l_trx_credit_limit IS NOT NULL) THEN
          l_amount_requested := l_trx_credit_limit;
        END IF;

        IF (l_amount_requested IS NOT NULL) THEN
          WF_ENGINE.SetItemAttrNumber(itemtype =>  itemtype,
                                      itemkey  =>  itemkey,
                                	  aname    =>  'REQUESTED_CREDIT_LIMIT',
                                	  avalue   =>  l_amount_requested );
        END IF;
        -- Fix for Bug 8660531 - End

        BEGIN
            SELECT party_id, decode(cust_account_id,-99,-1,cust_account_id),
                   decode(site_use_id,-99,null,site_use_id)
            INTO   l_party_id, l_cust_account_id, l_site_use_id
            FROM   ar_cmgt_credit_requests
            WHERE  credit_request_id = itemkey;

        END;
        l_case_folder_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CASE_FOLDER_ID');

        l_limit_currency :=  WF_ENGINE.getItemAttrText
                            (itemtype  =>  itemtype,
                             itemkey  =>  itemkey,
                             aname    =>  'LIMIT_CURRENCY');
      /* Update the risk factor data point value */

        BEGIN
            SELECT DECODE(to_number(NVL(cfd.data_point_value,'1')),0,1,NVL(cfd.data_point_value,'1'))
            INTO   l_exposure
            FROM   ar_cmgt_cf_dtls cfd
            WHERE  cfd.case_folder_id = l_case_folder_id
            AND    cfd.data_point_id = 34;
        EXCEPTION
            WHEN others THEN
            --If you dont put 1, this will cause a zero divide error
                l_exposure := 1;
        END;

        BEGIN
            SELECT nvl(overall_credit_limit,0)
            INTO   l_credit_limit
            FROM   hz_cust_profile_amts hzp
            WHERE  cust_account_profile_id = (
                       SELECT cust_account_profile_id
                          FROM hz_customer_profiles
                          WHERE party_id = l_party_id
                          AND   cust_account_id = l_cust_account_id
                          AND  ( site_use_id IS NULL
                                 OR site_use_id =  l_site_use_id))
            AND   currency_code = l_limit_currency;
        EXCEPTION
            WHEN OTHERS THEN
                l_credit_limit := 0;
        END;
        l_risk_factor := (1 - round((l_credit_limit/l_exposure),2));


        AR_CMGT_CONTROLS.UPDATE_CASE_FOLDER_DETAILS (
                    p_case_folder_id        =>  l_case_folder_id,
                    p_data_point_id         =>  182,
                    p_data_point_value      =>  l_risk_factor,
                    p_score                 =>  NULL,
                    p_errmsg                =>  l_errmsg,
                    p_resultout             =>  l_resultout);

        -- Now Release the parent credit request from HOLD(if any)
        BEGIN
        	SELECT a.parent_credit_request_id
        	INTO   l_parent_credit_request_id
        	FROM   ar_cmgt_credit_requests a, ar_cmgt_credit_requests b
        	WHERE  a.credit_request_id = itemkey
			AND    a.parent_credit_request_id = b.credit_request_id
			AND    b.status <> 'PROCESSED';

			-- rows exist, so start workflow
			ar_cmgt_wf_engine.start_workflow (
    			p_credit_request_id          => l_parent_credit_request_id,
    			p_application_status         => 'SUBMIT' );

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
				WHEN OTHERS THEN
					wf_core.context('AR_CMGT_WF_ENGINE','POST_IMPLEMENT_PROCESS',itemtype,
                            itemkey,
                            'Error while Getting Parent Credit Request Id',
                            sqlerrm);
                	raise;
        END;

    END IF;
END;


PROCEDURE IMPLEMENT_CUSTOM_RECO(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_case_folder_id        ar_cmgt_case_folders.case_folder_id%type;
    l_reco_name             ar_cmgt_cf_recommends.CREDIT_RECOMMENDATION%type;
    l_dayz                  AR_CMGT_SETUP_OPTIONS.CER_DSO_DAYS%TYPE;
    l_reco_id               ar_cmgt_cf_recommends.RECOMMENDATION_ID%TYPE;
    CURSOR reco_check IS
    SELECT CREDIT_RECOMMENDATION,RECOMMENDATION_ID
    FROM AR_CMGT_CF_RECOMMENDS
    WHERE CREDIT_REQUEST_ID = itemkey;
BEGIN

    select case_folder_id
    INTO   l_case_folder_id
    FROM   ar_cmgt_case_folders
    WHERE  credit_request_id = itemkey
    and    type = 'CASE';

    raise_recco_event(l_case_folder_id);
    EXCEPTION
        WHEN OTHERS THEN
            wf_core.context('AR_CMGT_WF_ENGINE','IMPLEMENT_CUSTOM_RECO',itemtype,
                            itemkey,'Error while raise Business Event',
                            sqlerrm);
            raise;




END;

PROCEDURE UPDATE_SKIP_APPROVAL_FLAG (
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_failure_function      VARCHAR2(60);
BEGIN
        l_failure_function := WF_ENGINE.getItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'FAILURE_FUNCTION');

        IF l_failure_function IS NULL OR l_failure_function <> 'SKIP_APPROVAL'
        THEN
            WF_ENGINE.setItemAttrText(
                        itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'SKIP_APPROVAL',
                        avalue   => 'N');
        END IF;

END;
PROCEDURE UPDATE_CF_TO_CREATE (
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_case_folder_id        ar_cmgt_case_folders.case_folder_id%type;
BEGIN
    l_case_folder_id := WF_ENGINE.GetItemAttrNumber
                    (itemtype => itemtype,
                     itemkey  => itemkey,
                     aname    => 'CASE_FOLDER_ID');

    UPDATE ar_cmgt_case_folders
        set status = 'CREATED',
            last_updated = sysdate,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id
    WHERE case_folder_id = l_case_folder_id;

END;

-- Fix for Bug 9317333 - Start
PROCEDURE update_credit_analyst_info(p_itemkey			IN	VARCHAR2,
                                     p_credit_analyst_id IN VARCHAR2) IS
  l_credit_analyst_id        NUMBER(15);
  l_orig_credit_analyst_id   NUMBER(15);
  l_prev_credit_analyst_id   NUMBER(15);
  l_case_folder_number       VARCHAR2(30);
  l_new_credit_analyst_id    VARCHAR2(40);

  CURSOR get_case_analyst_info IS
  SELECT credit_analyst_id, original_credit_analyst_id,
         previous_credit_analyst_id, case_folder_number
  FROM
         ar_cmgt_case_folders
  WHERE  credit_request_id = p_itemkey
  AND    type = 'CASE';
BEGIN

   l_new_credit_analyst_id := p_credit_analyst_id;

   OPEN get_case_analyst_info;
   FETCH get_case_analyst_info INTO l_credit_analyst_id, l_orig_credit_analyst_id,
                            l_prev_credit_analyst_id, l_case_folder_number;
   CLOSE get_case_analyst_info;

   IF (l_orig_credit_analyst_id IS NULL AND l_prev_credit_analyst_id IS NULL) THEN
     UPDATE ar_cmgt_case_folders
     SET original_credit_analyst_id = l_credit_analyst_id,
         previous_credit_analyst_id = l_credit_analyst_id
     WHERE case_folder_number = l_case_folder_number;
   ELSIF (l_orig_credit_analyst_id IS NOT NULL AND l_prev_credit_analyst_id IS NOT NULL) THEN
     IF (l_orig_credit_analyst_id = l_new_credit_analyst_id) THEN
       UPDATE ar_cmgt_case_folders
       SET original_credit_analyst_id = NULL,
           previous_credit_analyst_id = NULL
       WHERE case_folder_number = l_case_folder_number;
     ELSE
       UPDATE ar_cmgt_case_folders
       SET previous_credit_analyst_id = l_credit_analyst_id
       WHERE case_folder_number = l_case_folder_number;
     END IF;
   END IF;

END update_credit_analyst_info;
-- Fix for Bug 9317333 - End

/* This procedure is used tyo update a particular
 ** workflow item attribute, for eg. credit_analyst_id */
PROCEDURE UPDATE_WF_ATTRIBUTE (
	p_itemkey			IN		VARCHAR2,
    p_attribute_type    IN      VARCHAR2,
	p_attribute_name	IN		VARCHAR2,
	p_attribute_value	IN		VARCHAR2 ) IS

	l_person_id             per_people_f.person_id%type;
	l_user_name         VARCHAR2(60);
    l_display_name      VARCHAR2(240);

    -- Fix for Bug 7167583
    -- Cursor to retrieve the notification_id and the current user
    CURSOR get_notification_info IS
	SELECT wfn.notification_id, wfs.assigned_user
	FROM wf_item_activity_statuses wfs, wf_notifications wfn
	WHERE wfs.item_type = 'ARCMGTAP'
	AND  wfs.item_key = p_itemkey
	AND  wfs.notification_id is not null
	AND  wfs.notification_id = wfn.notification_id
	AND  wfn.status = 'OPEN';
	-- End fix for Bug 7167583

BEGIN
	IF p_attribute_type  = 'NUMBER'
	THEN
		WF_ENGINE.setItemAttrNumber(itemType => 'ARCMGTAP',
                                itemKey  => p_itemkey,
                                aname    => p_attribute_name,
                                avalue   => p_attribute_value);
    ELSIF p_attribute_type  = 'TEXT'
	THEN
		WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => p_itemkey,
                                aname    => p_attribute_name,
                                avalue   => p_attribute_value);
    END IF;
    IF p_attribute_name = 'CREDIT_ANALYST_ID'
    THEN
    	l_person_id := ar_cmgt_util.get_person_based_on_resource (
				l_resource_id  => to_number(p_attribute_value));

		-- now get credit_ananlyst details
		get_employee_details(l_person_id,l_user_name, l_display_name);
		WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => p_itemkey,
                                aname    => 'CREDIT_ANALYST_USER_NAME',
                                avalue   => l_user_name);
        WF_ENGINE.setItemAttrText(itemType => 'ARCMGTAP',
                                itemKey  => p_itemkey,
                                aname    => 'CREDIT_ANALYST_DISPLAY_NAME',
                                avalue   => l_display_name);

        -- Fix for Bug 7167583
		-- Transfer the notification from the current to new credit analyst
		FOR c_get_notification_info IN get_notification_info LOOP
  		  WF_NOTIFICATION.Transfer(nid                  => c_get_notification_info.notification_id,
                  				   new_role 			=> l_user_name,
                  				   forward_comment      => null,
                  				   user 				=> c_get_notification_info.assigned_user,
                  				   cnt 				    => 0,
                  				   action_source 		=> null);
		END LOOP;
		-- End fix for Bug 7167583

    END IF;

    -- Fix for Bug 9317333 - Start
    IF (p_attribute_value IS NOT NULL) THEN
      update_credit_analyst_info(p_itemkey			 => p_itemkey,
                                 p_credit_analyst_id => p_attribute_value);
    END IF;
    -- Fix for Bug 9317333 - End

END UPDATE_WF_ATTRIBUTE;

PROCEDURE CHECK_CHILD_REQ_COMPLETED(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

	l_credit_request_id			ar_cmgt_credit_requests.credit_request_id%type;
	l_credit_request_type		ar_cmgt_credit_requests.credit_request_type%type;
	l_status					ar_cmgt_case_folders.status%type;

BEGIN
	 IF  funcmode = 'RUN'
     THEN
     	BEGIN
     		SELECT r.credit_request_id, r.credit_request_type, r.status
     		INTO   l_credit_request_id, l_credit_request_type, l_status
     		FROM   ar_cmgt_credit_requests r
     		WHERE  r.parent_credit_request_id = itemkey
			AND    r.status <> 'PROCESSED';

     		resultout := 'COMPLETE:N';

		 EXCEPTION
		 	WHEN NO_DATA_FOUND	THEN
		 		-- mean no credit request exists
		 		resultout := 'COMPLETE:Y';
		 	WHEN TOO_MANY_ROWS	THEN
		 		-- mean no credit request exists
		 		resultout := 'COMPLETE:N';
		 	WHEN OTHERS THEN
		 		 wf_core.context('AR_CMGT_WF_ENGINE','CHECK_CHILD_REQ_COMPLETED',itemtype,
                            itemkey,'Error while Checking Child Credit Requests',
                            sqlerrm);
            	raise;
     	END;
     END IF;
END;

PROCEDURE VALIDATE_RECOMMENDATIONS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

	l_case_folder_id        ar_cmgt_case_folders.case_folder_id%TYPE;
	l_reco_exist            VARCHAR2(1) := 'N';
	l_credit_request_type	ar_cmgt_credit_requests.credit_request_type%type;
	l_flag				    varchar2(1);
	UNEXP_ERROR				EXCEPTION;
     --this will check if recommendations exists or not.
     CURSOR CHECK_RECO_EXISTS IS
   		SELECT 'Y'
        FROM ar_cmgt_cf_recommends
		WHERE CASE_FOLDER_ID=l_case_folder_id;

BEGIN
	IF  funcmode = 'RUN'
    THEN

		-- first validate for guarantors credit request
		-- there won't be any recommendations
		WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'VALIDATE_RECO');

        l_case_folder_id := WF_ENGINE.GetItemAttrNumber
		                            (itemtype => itemtype,
		                             itemkey  => itemkey,
                                      aname    => 'CASE_FOLDER_ID');
		l_credit_request_type := WF_ENGINE.GetItemAttrText
		                            (itemtype => itemtype,
		                             itemkey  => itemkey,
                                      aname    => 'CREDIT_REQUEST_TYPE');
    	--fetch the cursors
        OPEN CHECK_RECO_EXISTS;
       	FETCH CHECK_RECO_EXISTS INTO l_reco_exist;
        CLOSE CHECK_RECO_EXISTS;

    	-- if the request type is Guarantor then reco. is not allowed
    	IF nvl(l_credit_request_type,'CREDIT_APP') = 'GUARANTOR' and l_reco_exist = 'Y'
    	THEN
    		resultout := 'COMPLETE:FAILURE';
    		return;
    	END IF;

        --check both the flags before setting the
        -- generate flag to generate recommendation
        --cause if the recommendations aleready exist
        --we do not need to generate them. And in case
        --recommendations exists for guarantor then
        --we need to raise the error which will be raised
        --while validating the recommendations.

        IF l_reco_exist = 'N' and nvl(l_credit_request_type,'CREDIT_APP') <> 'GUARANTOR'
		THEN
                 --call the program for populating the recommendations
                 --before validating.
                 AR_CMGT_WF_ENGINE.GET_EXT_SCORE_RECOMMENDATIONS(
                                                       itemtype => itemtype,
						       						   itemkey  => itemkey,
                                                       p_cf_id  => l_case_folder_id,
                                                       resultout=> resultout);
                 IF resultout <> 0
                 THEN

             		raise UNEXP_ERROR;
                END IF;
        END IF;


		-- do the next validations
		BEGIN
        	SELECT 'X'
        	INTO   l_flag
        	FROM   ar_cmgt_cf_recommends cf, ar_cmgt_credit_requests req
        	WHERE  req.credit_request_id = itemkey
        	AND    req.credit_request_id = cf.credit_request_id
        	AND    req.cust_account_id = -99
        	AND    req.site_use_id = -99
        	AND    cf.credit_recommendation = 'CUST_HOLD';

        	resultout := 'COMPLETE:FAILURE';
			return;

		EXCEPTION
				WHEN NO_DATA_FOUND THEN
					resultout := 'COMPLETE:SUCESS';
				WHEN TOO_MANY_ROWS THEN
					resultout := 'COMPLETE:FAILURE';
					return;
				WHEN OTHERS THEN
		 	 		wf_core.context('AR_CMGT_WF_ENGINE','VALIDATE_RECOMMENDATIONS',itemtype,
                          itemkey,'Error while validating Recommendations for Party',
                            sqlerrm);
             	raise;

        END;
		-- validate again whether reco. has been created or not
        OPEN CHECK_RECO_EXISTS;
       	FETCH CHECK_RECO_EXISTS INTO l_reco_exist;
        CLOSE CHECK_RECO_EXISTS;
        IF l_reco_exist = 'Y' AND
            nvl(l_credit_request_type,'CREDIT_APP') <> 'GUARANTOR'
        THEN
            resultout := 'COMPLETE:SUCESS';
        ELSIF  nvl(l_credit_request_type,'CREDIT_APP') = 'GUARANTOR' and l_reco_exist = 'Y'
        THEN
            resultout := 'COMPLETE:FAILURE';
        ELSIF  nvl(l_credit_request_type,'CREDIT_APP') = 'GUARANTOR' and l_reco_exist = 'N'
        THEN
            resultout := 'COMPLETE:SUCESS';
        ELSE
            resultout := 'COMPLETE:FAILURE';
        END IF;
	END IF;
	EXCEPTION
		WHEN UNEXP_ERROR THEN
			wf_core.context('AR_CMGT_WF_ENGINE','VALIDATE_RECOMMENDATIONS',itemtype,
		                           itemkey,'Error while populating recommendation ',
		                             sqlerrm);
			raise;
END;

PROCEDURE MARK_REQUEST_ON_HOLD (
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

BEGIN
	IF funcmode = 'RUN'
    THEN

        WF_ENGINE.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'MANUAL_ANALYSIS_FLAG',
                                  avalue   => 'H');
    END IF;
END;

/*This procedure Duplicates all the data in case of Appeal/Re-Submit
----------------------------------------------------------------------*/
procedure APPEAL_RESUB_DECISION(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_case_folder_tbl_exp             EXCEPTION;
    l_case_folder_dtls_exp            EXCEPTION;
    l_aging_data                      EXCEPTION;
    l_dnb_data                        EXCEPTION;
    l_financial_data                  EXCEPTION;
    l_trade_data                      EXCEPTION;
    l_bank_data                       EXCEPTION;
    l_collateral_data                 EXCEPTION;
    l_other_data                      EXCEPTION;
    l_reco_data                       EXCEPTION;
    l_errmsg                        VARCHAR2(2000);
    l_resultout                     VARCHAR2(1);
    l_processng_flag                VARCHAR2(1);
    l_case_rec_num                  NUMBER;
    l_credit_type                   ar_cmgt_credit_requests.credit_type%type;
    l_credit_request_type	    	ar_cmgt_credit_requests.credit_request_type%type;
    l_case_folder_id                ar_cmgt_case_folders.case_folder_id%type;
    l_parent_cf_id                  ar_cmgt_case_folders.case_folder_id%type;
    l_parent_creq_id                ar_cmgt_credit_requests.parent_credit_request_id%type;
    insert_failure                  EXCEPTION;
    l_cf_id                         ar_cmgt_case_folders.case_folder_id%type;
    populate_failure                EXCEPTION;


BEGIN
    IF funcmode = 'RUN'
    THEN

            WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'DUPLICATE_CASE_FOLDER');


        --initialise the variables
          l_processng_flag := 'N';

        -- get credit type from credit requests
	BEGIN

        SELECT credit_request_type
        INTO   l_credit_request_type
        FROM   ar_cmgt_credit_requests
        WHERE  credit_request_id = itemkey;
	EXCEPTION
            WHEN OTHERS THEN
               wf_core.context ('AR_CMGT_WF_ENGINE','APPEAL_RESUB_DECISION',itemtype,itemkey,
                                 'Error while getting records from AR_CMGT_CREDIT_REQUESTS',
                                 'Sql Error: '||sqlerrm);
                raise;
        END;

        -- If the request is not "Appeal" or "Re-Submit"
	--then it follows the normal path.

        IF   l_credit_request_type = 'APPEAL'
		OR   l_credit_request_type = 'RESUBMIT'
        OR   l_credit_request_type = 'APPEAL_REJECTION'
        THEN
                l_processng_flag := 'Y';
		ELSE
        	resultout := 'COMPLETE:N';
        	return;
        END IF;

	-- The request is appeal and need to process
	IF l_processng_flag = 'Y'
    THEN

        --get parent credit request id

		BEGIN

			SELECT PARENT_CREDIT_REQUEST_ID
			INTO l_parent_creq_id
			FROM AR_CMGT_CREDIT_REQUESTS
			WHERE CREDIT_REQUEST_ID = itemkey;

        	EXCEPTION
            	WHEN OTHERS THEN
               		wf_core.context ('AR_CMGT_WF_ENGINE','APPEAL_RESUB_DECISION',itemtype,itemkey,
                                 'Error while getting parent records from AR_CMGT_CREDIT_REQUESTS',
                                 'Sql Error: '||sqlerrm);
                	raise;
    	END;

       --get case folder id for parent credit request

       BEGIN

       		SELECT CASE_FOLDER_ID
       		INTO l_parent_cf_id
       		FROM AR_CMGT_CASE_FOLDERS
       		WHERE CREDIT_REQUEST_ID = l_parent_creq_id
       		and type = 'CASE';

       		EXCEPTION
            	WHEN OTHERS THEN
               		wf_core.context ('AR_CMGT_WF_ENGINE','APPEAL_RESUB_DECISION',itemtype,itemkey,
                                 'Error while getting parent records from AR_CMGT_CASE_FOLDERS',
                                 'Sql Error: '||sqlerrm);
                raise;
        END;

       --generate case folder for new credit request.

       AR_CMGT_CONTROLS.DUPLICATE_CASE_FOLDER_TBL(
                        p_parnt_case_folder_id  => l_parent_cf_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);
       IF l_resultout <> 0
            THEN

		raise l_case_folder_tbl_exp;

            END IF;


      --populate the details of newly created case folder.
       IF l_resultout <> 0
            THEN
              raise populate_failure;
       END IF;

      AR_CMGT_CONTROLS.DUPLICATE_CASE_FOLDER_DTLS(
                        p_parnt_case_folder_id  => l_parent_cf_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

       IF l_resultout <> 0
            THEN
              raise l_case_folder_dtls_exp;
            END IF;


       --populate AR_CMGT_CF_AGING_DTLS

       AR_CMGT_CONTROLS.DUPLICATE_AGING_DATA(
                        p_parnt_case_folder_id  => l_parent_cf_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

       IF l_resultout <> 0
            THEN

                raise l_aging_data;
            END IF;

      --populate ar_cmgt_cf_dnb_dtls

     AR_CMGT_CONTROLS.DUPLICATE_DNB_DATA(
                        p_parnt_case_folder_id  => l_parent_cf_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

       IF l_resultout <> 0
            THEN

                raise l_dnb_data;
            END IF;

		--call the routine to populate all the wf_attributes
      AR_CMGT_WF_ENGINE.POPULATE_WF_ATTRIBUTES(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        actid     => actid,
                        funcmode  => funcmode,
                        p_called_from => 'APPEAL',
						resultout        => l_resultout);
        --populate AR_CMGT_CF_ANL_NOTES

     AR_CMGT_CONTROLS.DUPLICATE_NOTES_DATA(
                        p_parnt_case_folder_id  => l_parent_cf_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

       IF l_resultout <> 0
            THEN

                raise l_dnb_data;
            END IF;

       --populate ar_cmgt_financial_data

     AR_CMGT_CONTROLS.DUPLICATE_FINANCIAL_DATA(
                        p_parnt_credit_req_id   => l_parent_creq_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

       IF l_resultout <> 0
            THEN

                raise l_financial_data;
            END IF;


       --populate ar_cmgt_trade_ref_data

     AR_CMGT_CONTROLS.DUPLICATE_TRADE_DATA(
                        p_parnt_credit_req_id   => l_parent_creq_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

       IF l_resultout <> 0
            THEN

                raise l_trade_data;
            END IF;


       --populate ar_cmgt_bank_ref_data

     AR_CMGT_CONTROLS.DUPLICATE_BANK_DATA(
                        p_parnt_credit_req_id   => l_parent_creq_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

       IF l_resultout <> 0
            THEN

                raise l_bank_data;
            END IF;


       --populate ar_cmgt_collateral_data

      AR_CMGT_CONTROLS.DUPLICATE_COLLATERAL_DATA(
                        p_parnt_credit_req_id   => l_parent_creq_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout     	=> l_resultout);

       IF l_resultout <> 0
            THEN

                raise l_collateral_data;
            END IF;


       --populate ar_cmgt_other_data

     AR_CMGT_CONTROLS.DUPLICATE_OTHER_DATA(
                        p_parnt_credit_req_id   => l_parent_creq_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

       IF l_resultout <> 0
            THEN

                raise l_other_data;
            END IF;

     --populate ar_cmgt_cf_recommends

     AR_CMGT_CONTROLS.DUPLICATE_RECO_DATA(
                        p_parnt_case_folder_id  => to_number(l_parent_cf_id),
                        p_credit_request_id     => to_number(itemkey),
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

       IF l_resultout <> 0
            THEN

                raise l_reco_data;
            END IF;


       IF l_resultout = 0
       THEN
            resultout := 'COMPLETE:Y';
	    return;
       END IF;


       END IF;
       END IF;
END APPEAL_RESUB_DECISION;

/*This procedure populates all the wf_attributes
-------------------------------------------------------------------------------------*/
PROCEDURE POPULATE_WF_ATTRIBUTES (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    p_called_from	IN		VARCHAR2,
    resultout       out NOCOPY     varchar2) IS

    l_credit_classification     ar_cmgt_check_lists.credit_classification%TYPE;
    l_review_type               ar_cmgt_check_lists.review_type%TYPE;
    l_check_list_id             ar_cmgt_check_lists.check_list_id%TYPE;
    l_score_model_id            ar_cmgt_scores.score_model_id%TYPE;
    l_currency                  ar_cmgt_credit_requests.limit_currency%TYPE;
    l_amount_requested          ar_cmgt_credit_requests.limit_amount%TYPE;
    l_case_folder_number        ar_cmgt_case_folders.case_folder_number%type;
    l_source_name               ar_cmgt_credit_requests.source_name%type;
    l_classification_meaning    ar_lookups.meaning%type;
    l_review_type_meaning       ar_lookups.meaning%type;
    l_application_number        ar_cmgt_credit_requests.application_number%type;
    l_score_model_already_set   VARCHAR2(1) := 'F';
    l_requestor_id              ar_cmgt_credit_requests.requestor_id%type;
    l_requestor_user_name       fnd_user.user_name%type;
    l_requestor_display_name    per_people_f.full_name%type;
    l_party_id					hz_parties.party_id%type;
    l_cust_account_id			hz_cust_accounts.cust_account_id%type;
    l_party_name				hz_parties.party_name%type;
    l_party_number				hz_parties.party_number%type;
    l_account_number			hz_cust_accounts.account_number%type;
    l_application_date			ar_cmgt_credit_requests.application_date%type;
    l_source_column1			ar_cmgt_credit_requests.source_column1%type;
    l_source_column2			ar_cmgt_credit_requests.source_column2%type;
    l_source_column3			ar_cmgt_credit_requests.source_column3%type;
    l_notes						ar_cmgt_credit_requests.notes%type;
    l_case_folder_id            ar_cmgt_case_folders.case_folder_id%TYPE;
    l_limit_currency			ar_cmgt_case_folders.limit_currency%TYPE;
    l_creation_date_time		ar_cmgt_case_folders.creation_date_time%TYPE;
    l_requestor_type			ar_cmgt_credit_requests.requestor_type%TYPE;

BEGIN
    IF funcmode = 'RUN'
    THEN

        BEGIN
            SELECT req.credit_classification, req.review_type,
                   nvl(req.limit_currency, trx_currency),
                   nvl(nvl(req.limit_amount,req.trx_amount),0),
                   req.case_folder_number, req.score_model_id, req.source_name,
                   req.application_number,
                   lkp1.meaning classification_meaning,
                   lkp2.meaning review_type_meaning,
                   requestor_id,
                   application_date,
                   req.party_id,
                   cust_account_id,
                   source_column1,
                   source_column2,
                   source_column3,
                   party.party_name,
                   party.party_number,
                   req.notes,
                   nvl(req.requestor_type, 'EMPLOYEE')
            INTO   l_credit_classification, l_review_type, l_currency,
                   l_amount_requested, l_case_folder_number, l_score_model_id,
                   l_source_name, l_application_number,
                   l_classification_meaning,
                   l_review_type_meaning,
                   l_requestor_id,
                   l_application_date,
                   l_party_id,
                   l_cust_account_id,
                   l_source_column1,
                   l_source_column2,
                   l_source_column3,
                   l_party_name,
                   l_party_number,
                   l_notes,
                   l_requestor_type
            FROM   ar_cmgt_credit_requests req,
                   ar_lookups lkp1,
                   ar_lookups lkp2,
                   hz_parties party
            WHERE  req.credit_request_id = itemkey
            AND    req.party_id = party.party_id
            AND    lkp1.lookup_type = 'AR_CMGT_CREDIT_CLASSIFICATION'
            AND    lkp1.lookup_code = req.credit_classification
            AND    lkp2.lookup_type = 'AR_CMGT_REVIEW_TYPE'
            AND    lkp2.lookup_code = req.review_type;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                SELECT req.credit_classification, req.review_type, req.application_number,
                       req.score_model_id,
                       application_date,
                   	   req.party_id,
                   	   cust_account_id,
                   	   source_column1,
                   	   source_column2,
                   	   source_column3,
                   	   party.party_name,
                   	   party.party_number,
                   	   req.notes,
                   	   req.requestor_id,
                   	   req.source_name,
                   	   req.case_folder_number,
					   nvl(req.limit_currency, trx_currency),
                   	   nvl(nvl(req.limit_amount,req.trx_amount),0),
                   	   nvl(req.requestor_type, 'EMPLOYEE')
                INTO   l_credit_classification, l_review_type, l_application_number,
                       l_score_model_id,
                    	l_application_date,
                   		l_party_id,
                   		l_cust_account_id,
                   		l_source_column1,
                   		l_source_column2,
                   		l_source_column3,
                   		l_party_name,
                   	    l_party_number,
                   	    l_notes,
                   	    l_requestor_id,
                   	    l_source_name,
                   	    l_case_folder_number,
                   	    l_currency,
                   	    l_amount_requested,
                   	    l_requestor_type
                FROM   ar_cmgt_credit_requests req,
                	   hz_parties party
                WHERE  credit_request_id = itemkey
				AND    req.party_id = party.party_id;
            WHEN OTHERS THEN
                wf_core.context ('AR_CMGT_WF_ENGINE','POPULATE_WF_ATTRIBUTES',itemtype,itemkey,
                                 sqlerrm);
                raise;
        END;

        WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'PARTY_ID',
                                avalue   =>  l_party_id );

        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'CREDIT_CLASSIFICATION',
                                avalue   =>  l_credit_classification );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REVIEW_TYPE',
                                avalue   =>  l_review_type );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'CURRENCY',
                                avalue   =>  l_currency );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'SOURCE_NAME',
                                avalue   =>  l_source_name );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'APPLICATION_NUMBER',
                                avalue   =>  l_application_number );
        WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTED_CREDIT_LIMIT',
                                avalue   =>  l_amount_requested );
        WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_PERSON_ID',
                                avalue   =>  l_requestor_id );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'SOURCE_COL1',
                                avalue   =>  l_source_column1 );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'SOURCE_COL2',
                                avalue   =>  l_source_column2 );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'SOURCE_COL3',
                                avalue   =>  l_source_column3 );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'PARTY_NAME',
                                avalue   =>  l_party_name );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'PARTY_NUMBER',
                                avalue   =>  l_party_number );
        WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'APPL_NOTES',
                                avalue   =>  l_notes );
        WF_ENGINE.SetItemAttrDate(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'APPLICATION_DATE',
                                avalue   =>  l_application_date );

        IF l_requestor_type = 'EMPLOYEE'
        THEN
        	get_employee_details(
                p_employee_id        => l_requestor_id,
                p_user_name          => l_requestor_user_name,
                p_display_name       => l_requestor_display_name);

        	WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_USER_NAME',
                                avalue   =>  l_requestor_user_name );
        	WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_DISPLAY_NAME',
                                avalue   =>  l_requestor_display_name );
		ELSE
			-- get user id
			BEGIN
					SELECT user_name
					INTO   l_requestor_user_name
					FROM   fnd_user
					WHERE  user_id = l_requestor_id;

					WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_USER_NAME',
                                avalue   =>  l_requestor_user_name );

					WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'REQUESTOR_DISPLAY_NAME',
                                avalue   =>  l_requestor_user_name );
					EXCEPTION
						WHEN NO_DATA_FOUND THEN
							wf_core.context ('AR_CMGT_WF_ENGINE','POPULATE_WF_ATTRIBUTE',itemtype,itemkey,
                                 'FND User Not Found'|| sqlerrm);
                			raise;
						WHEN OTHERS THEN
							wf_core.context ('AR_CMGT_WF_ENGINE','POPULATE_WF_ATTRIBUTE',itemtype,itemkey,
                                 'Other Error '|| sqlerrm);
                			raise;
			END;
        END IF;
        -- check if the application is on accounts level and set the account Number
        IF l_cust_account_id <> -99
        THEN
        	BEGIN
        		SELECT ACCOUNT_NUMBER
        		INTO   l_account_number
        		FROM   hz_cust_accounts
				WHERE  cust_account_id = l_cust_account_id;
        	EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_account_number := null;
				WHEN OTHERS THEN
                	wf_core.context ('AR_CMGT_WF_ENGINE','POPULATE_WF_ATTRIBUTES',itemtype,itemkey,
                                 'Getting Account Details SqlError: '|| sqlerrm);
                	raise;

        	END;
        	WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'ACCOUNT_NUMBER',
                                avalue   =>  l_account_number );
        END IF;


        IF p_called_from = 'APPEAL'
        THEN
        	-- Get case folder details
        	BEGIN
        		SELECT case_folder_id, case_folder_number, check_list_id, score_model_id,
        			   limit_currency, creation_date_time
				INTO   l_case_folder_id, l_case_folder_number, l_check_list_id, l_score_model_id,
					   l_limit_currency, l_creation_date_time
				FROM   ar_cmgt_case_folders
				WHERE  credit_request_id = itemkey
				AND    type = 'CASE';

				WF_ENGINE.setItemAttrNumber
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'CASE_FOLDER_ID',
                         avalue    => l_case_folder_id);

				WF_ENGINE.setItemAttrText
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'LIMIT_CURRENCY',
                         avalue    => l_limit_currency);


				WF_ENGINE.setItemAttrText
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'CASE_FOLDER_NUMBER',
                         avalue    => l_case_folder_number);


				WF_ENGINE.setItemAttrDate
                        (itemtype  => itemtype,
                         itemkey   => itemkey,
                         aname     => 'CASE_FOLDER_DATE',
                         avalue    => l_creation_date_time);

				WF_ENGINE.setItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'CHECK_LIST_ID',
                                    avalue    => l_check_list_id);

				WF_ENGINE.setItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'SCORE_MODEL_ID',
                                    avalue    => l_score_model_id);
            EXCEPTION
            	WHEN OTHERS THEN
            		wf_core.context ('AR_CMGT_WF_ENGINE','POPULATE_WF_ATTRIBUTES',itemtype,itemkey,
                                 'Error while getting Case Folder Details, SqlError: '|| sqlerrm);
                	raise;
        	END;
        END IF;
    END IF;
END;

/* ***************************************************
Here we check for the data point External Score      *
*If the Data point Name (Will substitute it later    *
*with data Point Id.) is External Score.The Workflow *
*will call the Conc. program and raise the business  *
*event.                                              *
******************************************************/
procedure CHECK_EXTRNAL_DATA_POINTS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) IS

    l_score_model_id            NUMBER;
    l_case_folder_id            NUMBER;
    l_data_point_id             NUMBER;
    l_data_point_value          ar_cmgt_cf_dtls.data_point_value%type;
    l_data_point_type           VARCHAR2(255);
    l_null_zero_flag            VARCHAR2(1);
    l_success_flg               VARCHAR2(1);
    l_data_point_name           AR_CMGT_SCORABLE_DATA_POINTS_V.DATA_POINT_NAME%type;
    l_raise_event               VARCHAR2(1);
    l_cf_number                 ar_cmgt_case_folders.case_folder_number%type;
    l_request_id                NUMBER;
    l_list                      WF_PARAMETER_LIST_T;
    l_param                     WF_PARAMETER_T;
    l_key                       VARCHAR2(240);
    l_event_name                VARCHAR2(240) := 'oracle.apps.ar.cmgt.CaseFolder.extract';
    UNEXP_ERROR					EXCEPTION;

    CURSOR dp_id_collec IS
    select sc.data_point_id, dp.data_point_code
    from ar_cmgt_score_dtls sc, ar_cmgt_data_points_vl dp
    where sc.score_model_id= l_score_model_id
    AND   sc.data_point_id = dp.data_point_id
    AND   dp.data_point_code = 'OCM_EXTERNAL_SCORE';

BEGIN
    IF funcmode = 'RUN'
    THEN

    --initialize raise BE flag to 'N'
    l_raise_event:='N';

       WF_ENGINE.SetItemAttrText(itemtype  =>  itemtype,
                                itemkey  =>  itemkey,
                                aname    =>  'FAILURE_FUNCTION',
                                avalue   =>  'CHECK_EXTRNAL_DATA_POINTS');
        l_score_model_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SCORE_MODEL_ID');
        l_case_folder_id := WF_ENGINE.GetItemAttrNumber
                            (itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CASE_FOLDER_ID');
       IF pg_wf_debug = 'Y'
       THEN
       		debug('In Procedure CHECK_EXTRNAL_DATA_POINTS ++ for case folder id:'||l_case_folder_id);
       END IF;
	--get the data point data name(Id) for each data point
	--and compare to check if External Score data point Exists.

	FOR dp_id_collec_rec IN dp_id_collec
	LOOP

            IF dp_id_collec_rec.data_point_code = 'OCM_EXTERNAL_SCORE'
            THEN
                l_raise_event := 'Y';
            END IF;

    END LOOP;
	   -- Check for the result if result is Success
	   -- and raise aise BE flag is 'Y' spawn the Conc. program and
	    -- then raise the BE
    IF l_raise_event = 'Y'
    THEN
    	l_request_id :=0;
    	submit_xml_case_folder (
    		p_case_folder_id	=> l_case_folder_id,
    		p_request_id		=> l_request_id);

		IF l_request_id <> 0
		THEN
			resultout := 'COMPLETE:Y';
            UPDATE ar_cmgt_case_folders
      		SET request_id = l_request_id,
	    		status = 'IN_PROCESS',
	    		last_update_date = sysdate,
	    		last_updated_by = fnd_global.user_id,
	    		last_update_login = fnd_global.login_id
      		WHERE case_folder_id = l_case_folder_id;
      		return;
      	ELSE
      		resultout := 'COMPLETE:N';
      		raise UNEXP_ERROR;
		END IF;
    ELSIF l_raise_event = 'N'
    THEN
         resultout := 'COMPLETE:N';
    END IF;
    END IF;
	EXCEPTION
		WHEN  UNEXP_ERROR THEN
			wf_core.context ('AR_CMGT_WF_ENGINE','CHECK_EXTRNAL_DATA_POINTS',itemtype,itemkey,
                                 'Error while submitting Con. Request Id, SqlError: '|| sqlerrm);
            raise;
END;
PROCEDURE GET_EXT_SCORE_RECOMMENDATIONS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	p_cf_id         in      NUMBER,
	resultout		out     NOCOPY	varchar2) IS

        l_score                         NUMBER;
        l_score_model_id                ar_cmgt_case_folders.score_model_id%type;
        l_credit_type                   ar_cmgt_credit_requests.credit_type%type;
        l_resultout                     VARCHAR2(1);
        l_errmsg                        VARCHAR2(32767);
        l_credit_limit                  NUMBER := 0;
        insert_failure                  EXCEPTION;
        l_auto_rules_id                 ar_cmgt_auto_rules.auto_rules_id%type;

        --get score

        CURSOR GET_SCORE IS
        SELECT sum(nvl(SCORE,0))
        FROM AR_CMGT_CF_DTLS
        WHERE CASE_FOLDER_ID=p_cf_id;


        --get detailz
        CURSOR get_details IS
        SELECT cf.score_model_id,cr.credit_type
        from ar_cmgt_case_folders cf,ar_cmgt_credit_requests cr
        where case_folder_id=p_cf_id
        and cr.credit_request_id=cf.credit_request_id;


        --get auto rule id

        CURSOR get_auto_id IS
        SELECT auto_rules_id
		FROM ar_cmgt_auto_rules
		WHERE score_model_id=l_score_model_id
		AND Trunc(SYSDATE) BETWEEN Trunc(start_date) AND Trunc(Nvl(end_date,SYSDATE))
        AND submit_flag='Y';

        -- get recommendations

        CURSOR c_auto_reco IS
		SELECT a.credit_recommendation, a.recommendation_value1,
				a.recommendation_value2
		FROM   ar_cmgt_auto_recommends a, ar_cmgt_auto_rule_dtls b
		WHERE  a.auto_rule_details_id = b.auto_rule_details_id
		AND    l_score between b.credit_score_low and b.credit_score_high
		AND    a.credit_type = l_credit_type
        AND    b.auto_rules_id = l_auto_rules_id;

BEGIN

     --get the score

      OPEN GET_SCORE;
      FETCH GET_SCORE into l_score;
      CLOSE GET_SCORE;

    --get the detailz

      OPEN get_details;
      FETCH get_details INTO l_score_model_id,
                             l_credit_type;
      CLOSE get_details;
   --get auto rule id

      OPEN get_auto_id;
      FETCH get_auto_id into l_auto_rules_id;
      CLOSE get_auto_id;
   --loop through the auto rule cursor
   		FOR c_auto_rec IN c_auto_reco
        LOOP

            AR_CMGT_CONTROLS.populate_recommendation(
                        p_case_folder_id        => p_cf_id,
                        p_credit_request_id     => to_number(itemkey),
                        p_score                 => l_score,
                        p_recommended_credit_limit  => l_credit_limit,
                        p_credit_review_date    => sysdate,
                        p_credit_recommendation => c_auto_rec.credit_recommendation,
                        p_recommendation_value1 => c_auto_rec.recommendation_value1,
                        p_recommendation_value2 => trunc(c_auto_rec.recommendation_value2),
                        p_status                => 'O',
                        p_credit_type           => l_credit_type,
                        p_errmsg                => l_errmsg,
                        p_resultout             => l_resultout);

            IF l_resultout <> 0
            THEN
            --   raise insert_failure;
            	resultout :=l_resultout;
            	return;
            ELSE
            	resultout :=l_resultout;
            END IF;
        END LOOP;

END GET_EXT_SCORE_RECOMMENDATIONS;

PROCEDURE submit_xml_case_folder (
    		p_case_folder_id	IN NUMBER,
    		p_request_id		OUT NOCOPY NUMBER  ) IS
BEGIN
	IF p_case_folder_id IS NOT NULL
	THEN
		p_request_id := FND_REQUEST.SUBMIT_REQUEST('AR','OCMXMLCASEFOLDER',
                null,
                null,
                FALSE,
                p_case_folder_id,chr(0)
                ,'','','','','','','',''
                ,'','','','','','','','','',''
                ,'','','','','','','','','',''
                ,'','','','','','','','','',''
                ,'','','','','','','','','',''
                ,'','','','','','','','','',''
                ,'','','','','','','','','',''
                ,'','','','','','','','','',''
                ,'','','','','','','','','',''
                ,'','','','','','','','','','');
    	/* IF p_request_id <> 0
    	THEN
    		 UPDATE ar_cmgt_case_folders
      		SET request_id = p_request_id,
	    		status = 'IN_PROCESS',
	    		last_update_date = sysdate,
	    		last_updated_by = fnd_global.user_id
      		WHERE case_folder_id = p_case_folder_id;
    	END IF; */
	END IF;
	EXCEPTION
		WHEN OTHERS THEN
			raise;
END;


END AR_CMGT_WF_ENGINE;

/
