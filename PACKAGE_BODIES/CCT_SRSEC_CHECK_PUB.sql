--------------------------------------------------------
--  DDL for Package Body CCT_SRSEC_CHECK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_SRSEC_CHECK_PUB" as
/* $Header: cctsrseb.pls 120.1 2005/11/14 14:01:03 ibyon noship $ */
procedure authenticate_agents(p_srnum IN Varchar2,
                              p_agentIDs IN OUT NOCOPY Varchar2,
                              p_isServerGroupID IN Varchar2,
                              x_return_status OUT NOCOPY Varchar2)
--procedure TestSRSecurityT(p_table IN OUT NOCOPY System.CCT_AGENT_RESP_APP_ID_NST )
IS
    i BINARY_INTEGER;
    totalRec BINARY_INTEGER;
    status varchar2(1);
    agentID NUMBER(15,0);
    respID NUMBER(15,0);
    appID  NUMBER(15,0);
    secFlag Varchar2(1);
    p_table System.CCT_AGENT_RESP_APP_ID_NST;
    p_obj System.CCT_AGENT_RESP_APP_ID_OBJ;
    l_agentIDs Varchar2(32767);

    --TYPE cur_typ IS REF CURSOR;
    --c cur_typ;
    --query_str VARCHAR2(32767);

    CURSOR l_agents_csr IS
         SELECT agent_id, resp_id, app_id  FROM cct_agent_rt_stats
         WHERE agent_id IN (p_agentIDs) AND attribute1 = 'T';

    BEGIN
        x_return_status := FND_API.G_FALSE;
        If (p_agentIDs is null) THEN
          return;
        End If;


        /*  agentID:=obj.AGENT_ID;  */
/*          respID:=obj.RESPONSIBILITY_ID;  */
/*          appID:=obj.APPLICATION_ID;  */
/*          secFlag:=obj.SECURITY_YN_FLAG;  */

        p_table :=  System.CCT_AGENT_RESP_APP_ID_NST(System.CCT_AGENT_RESP_APP_ID_OBJ(0,0,0,''));
        i := p_table.FIRST;
        --tbd : change "F" to "T" as that's what we want here..
        -- If p_isServerGroupID is true, then p_agentIDs represents "Super Server Group ID".
        -- p_agentIDs := '('||p_agentIDs||')'; Bug 4283551 - do not use literal in sql. replaced with cursor
        --query_str := 'SELECT agent_id, resp_id, app_id  FROM cct_agent_rt_stats
        --              WHERE agent_id IN'||p_agentIDs ||' AND attribute1 = ''T'' ';
        --p_agentIDs := '';


        OPEN l_agents_csr;
        LOOP
            FETCH l_agents_csr INTO agentID,respID,appID;
            EXIT WHEN l_agents_csr%NOTFOUND;
            p_obj := System.CCT_AGENT_RESP_APP_ID_OBJ(TO_NUMBER(agentID),TO_NUMBER(respID),TO_NUMBER(appID),'N');
            p_table(i) := p_obj;
            i := i + 1;
            p_table.EXTEND();
            --dbms_output.put_line('Value of aID='||agentID||' resp_id='||respID||' app_id='||appID);
            -- process row here
        END LOOP;
        CLOSE l_agents_csr;
        p_agentIDs := '';
        --Last element is the 'null' element we initialized nested table.
        --Since atleast one valid agentID will always be passed 'p_table' won't have count==0.
        p_table.DELETE(p_table.LAST);

        --Display the Nested Table Data.
        --i := p_table.FIRST;
        --while (i <= p_table.LAST) LOOP
        --p_obj := p_table(i);
      --dbms_output.put_line (' Value of varray is ' || p_obj.AGENT_ID ||' '|| p_obj.RESPONSIBILITY_ID||' '||p_obj.APPLICATION_ID);
        --i := p_table.NEXT(i);
        --END LOOP;

        --It could happen that, p_table has 0 count. As none of agents were logged in.
        totalRec := p_table.COUNT;
        --dbms_output.put_line ('Value of runtime level is '||FND_LOG.G_CURRENT_RUNTIME_LEVEL);
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cct.plsql.cct_srsec_check_pub.authenticate_agents', 'No of Records in Nested table p_table is = '||totalRec);
        end if;

        if (totalRec < 1) then
           return;
        end if;

        CCT_SRSEC_CHECK_PUB.CallSRSecurityCheck(p_srnum,p_table,status);

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cct.plsql.cct_srsec_check_pub.authenticate_agents', 'Status returned from CallSRSecurityCheck() API is = '||status );
        end if;

        --Error'd out in API or No SR Security Check API found so return.
        if (status = FND_API.G_FALSE) then
           return;
        end if;
        --Build comma seperated agent list from Nested Table returned from SR SEcurity check api.

        --Display the Nested Table Data.
       -- i := p_table.FIRST;
       -- while (i <= p_table.LAST) LOOP
       -- p_obj := p_table(i);
       -- dbms_output.put_line ('YYY Value of varray is ' || p_obj.AGENT_ID ||' '|| p_obj.RESPONSIBILITY_ID||' '||p_obj.APPLICATION_ID||' '||p_obj.SECURITY_YN_FLAG);
       -- i := p_table.NEXT(i);
       -- END LOOP;


        i := p_table.FIRST;
        p_obj := p_table(i);
        if ((p_obj is not null) AND (p_obj.SECURITY_YN_FLAG = 'Y') ) THEN
            l_agentIDs := p_obj.AGENT_ID;
        end if;

        if (totalRec=1) then
          if (l_agentIDs is not null) then
            x_return_status := FND_API.G_TRUE;
            p_agentIDs := l_agentIDs;
            return;
          else
            p_agentIDs := '';
            return;
          end if;
        end if;

        i := p_table.NEXT(i);

        while (i <= p_table.LAST) LOOP
          p_obj := p_table(i);
          if ((p_obj is not null) AND (p_obj.SECURITY_YN_FLAG = 'Y') ) THEN
             l_agentIDs := l_agentIDs ||',' ||p_obj.AGENT_ID;
          end if;
          i := p_table.NEXT(i);
        END LOOP;
        --dbms_output.put_line (' Value of returned AgentID is ' ||l_agentIDs);
        p_agentIDs := l_agentIDs;
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cct.plsql.cct_srsec_check_pub.authenticate_agents', 'AgentIDs returned are = '||p_agentIDs );
        end if;
        x_return_status := FND_API.G_TRUE;
   --dbms_output.put_line('In TestSRSecurityT Proc '||SQLERRM(STATUS));
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('CCT','CCT_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN(TOKEN =>'ERROR_CODE' , VALUE=>sqlcode);
    FND_MESSAGE.SET_TOKEN(TOKEN =>'ERROR_MESSAGE', VALUE=>sqlerrm);
    FND_MSG_PUB.add;

    IF l_agents_csr%ISOPEN THEN
       CLOSE l_agents_csr;
    END IF;
    x_return_status := FND_API.G_FALSE;
END authenticate_agents;

procedure CallSRSecurityCheck(p_srnum IN Varchar2,p_table in out NOCOPY system.CCT_AGENT_RESP_APP_ID_NST, x_return_status out NOCOPY varchar2)
IS
    l_ver NUMBER(15,0);
    l_srKeyName Varchar2(64);
    status NUMERIC;
    return_status varchar2(1);
BEGIN
  x_return_status := FND_API.G_FALSE;
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cct.plsql.cct_srsec_check_pub.CallSRSecurityCheck.begin', '' );
  end if;
  BEGIN
    SELECT Count(*) INTO l_ver
    FROM cct_security_functions
    WHERE application_id=170 AND version=1.0 ;
  EXCEPTION
    When Others Then
    status := SQLCODE;
    if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cct.plsql.cct_srsec_check_pub.CallSRSecurityCheck', 'Exception while querying cct_security_functions table. '||SQLERRM(status) );
    end if;

    --dbms_output.put_line('In CallSRSecurityCheck Proc '||SQLERRM(STATUS));
    return;
  END;
-- Logic for executing correct version of API based on SR product installation
-- when we get to version 2.0 is ..
-- If (version 2.0 is present )
--   Execute an API for ver2.0
--else if (version 1.0 ispresent)
--   Execute an API for ver1.0;
-- Same pattern can be repeated when we get to version 3.0.

  --Here ORS ensures that there is valid SR Number value before making call to
  --authenticate_agents API.
  if (l_ver is not null) then
   l_srKeyName := CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_REQUEST_NUMBER;
   BEGIN
--   CCT_SRSEC_CHECK_PUB.validate_security(:1,:2,:3,:4);
    EXECUTE IMMEDIATE
     'BEGIN
      sr_uwq_integ.validate_security(:1,:2,:3,:4);
     END;'
     USING l_srKeyName,p_srnum,IN OUT p_table, OUT x_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      status := SQLCODE;
      if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cct.plsql.cct_srsec_check_pub.CallSRSecurityCheck', 'Exception was raised. '||SQLERRM(status) );
      end if;

      --dbms_output.put_line('Exception while executing  validate_security() Proc '||SQLERRM(STATUS));
      return;
    END;
      --raise_application_error(-20000, sqlerrm || '. Could not add column')  ;
  ELSE
    --Couldn't find an SR Security Check API so return.
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cct.plsql.cct_srsec_check_pub.CallSRSecurityCheck', 'Can not find Service Request Security Check API' );
    end if;
    return;
  end if;

  x_return_status := FND_API.G_TRUE;
END CallSRSecurityCheck;

END CCT_SRSEC_CHECK_PUB;

/
