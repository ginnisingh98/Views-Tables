--------------------------------------------------------
--  DDL for Package Body IEC_SVR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_SVR_UTIL_PVT" AS
/* $Header: IECVSVRB.pls 115.12 2004/04/09 15:46:58 minwang ship $ */

-- Sub-Program Unit Declarations

PROCEDURE UPDATE_SVR_RT_INFO
  (P_SERVER_ID       IN            NUMBER
  ,P_COMP_DEF_ID     IN            NUMBER
  ,P_DNS_NAME        IN            VARCHAR2
  ,P_IP_ADDRESS      IN            VARCHAR2
  ,P_WIRE_PROTOCOL   IN            VARCHAR2
  ,P_PORT            IN            NUMBER
  ,P_EXTRA           IN            VARCHAR2
  ,X_RESULT          IN OUT NOCOPY NUMBER
  )
AS

  l_result NUMBER;
  l_seq_id NUMBER;

BEGIN

  l_seq_id := 0;

  IF( ( P_SERVER_ID is null ) OR
      ( P_COMP_DEF_ID is null )
    )
  THEN
    raise_application_error
      ( -20000
       , 'P_SERVER_ID or P_COMP_DEF_ID  cannot be null.'
         || 'Values sent are server id (' || P_SERVER_ID || ')'
         || 'comp def id (' || P_COMP_DEF_ID || ')'
       ,TRUE
      );
   END IF;

--   dbms_output.put_line('IEC_SVR_UTIL_PVT: Update_svr_rt_info:  Done null check..');

   l_result := 0;

   BEGIN
      select comp_id into l_seq_id
        from  ieo_svr_comps
       where  server_id = P_SERVER_ID
         and  comp_def_id = P_COMP_DEF_ID;

      IF ( l_seq_id >  0 )
      THEN
 --       dbms_output.put_line('IEC_SVR_UTIL_PVT: Update_svr_rt_info: Comp_id is <' || l_seq_id || '>');
        l_result := l_seq_id;

        update ieo_svr_servers
           set dns_name = P_DNS_NAME,
               ip_address = P_IP_ADDRESS,
               last_update_date = sysdate
         where server_id = P_SERVER_ID;


        update ieo_svr_protocol_map
           set wire_protocol = P_WIRE_PROTOCOL,
               port = P_PORT,
               extra = P_EXTRA,
               last_updated_by = NVL(FND_GLOBAL.user_id,-1),
               last_update_date = sysdate
         where comp_id = l_seq_id;

	if (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) then
               insert into ieo_svr_protocol_map (
                                   comp_id,
                                   wire_protocol,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login,
                                   port,
                                   extra )
                            values (
                                   l_seq_id,
                                   P_WIRE_PROTOCOL,
                                   NVL(FND_GLOBAL.user_id,-1),
                                   sysdate,
                                   NVL(FND_GLOBAL.conc_login_id,-1),
                                   sysdate,
                                   NVL(FND_GLOBAL.conc_login_id,-1),
                                   P_PORT,
                                   P_EXTRA);
       end if;
    END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	null;
        RAISE;
   END;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END UPDATE_SVR_RT_INFO;

END IEC_SVR_UTIL_PVT;

/
