--------------------------------------------------------
--  DDL for Package Body XXAH_PROFORMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_PROFORMA" IS
  PROCEDURE Terminate_proforma(errbuf VARCHAR2
                              ,retcode NUMBER
                              ,p_number_of_days NUMBER) IS
    CURSOR c_sub(b_date DATE) IS
    SELECT sub_type.name
    ,      sub.order_number sub_number
    ,      sub.flow_status_code sub_status
    ,      main.flow_status_code main_status
    ,      main.order_number main_number
    ,      sub.header_id sub_header_id
    ,      sub.version_number sub_version
    from oe_blanket_headers main
    ,    oe_blanket_headers_all_dfv m_dfv
    ,    oe_blanket_headers_all sub
    ,    oe_transaction_types_tl sub_type
    where to_char(main.order_number) = sub.attribute12
    and sub_type.transaction_type_id = sub.order_type_id
    and sub_type.language = 'US'
    and upper(sub_type.name) like '%PROFORMA%'
    and sub.flow_status_code != 'TERMINATED'
    and main.flow_status_code = 'ACTIVE'
    AND main.rowid = m_dfv.row_id
    and m_dfv.actual_date_active >= nvl(b_date,m_dfv.actual_date_active)
    ;
    v_return_status VARCHAR2(1);
    v_msg_count NUMBER;
    v_msg_data VARCHAR2(2000);
    v_date DATE;
  BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_number_of_days: '||p_number_of_days);
    v_date := sysdate - p_number_of_days;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'v_date: '||v_date);

    FOR v_sub IN c_sub(v_date) LOOP
    
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Order header ID '||v_sub.sub_header_id);
      Oe_Oe_Form_Reasons.Apply_Reason(p_reason_type => 'CONTRACT_TERMINATION'
                                     ,p_reason_code => 'MAIN_ACTIVE'
                                     ,p_comments => NULL
                                     ,p_entity_id => v_sub.sub_header_id
                                     ,p_version_number => v_sub.sub_version
                                     ,p_entity_code => 'BLANKET_HEADER'
                                     ,x_return_status => v_return_status
                                     ,x_msg_count => v_msg_count
                                     ,x_msg_data => v_msg_data);
      IF v_return_status != 'S' THEN
        fnd_file.put_line(fnd_file.OUTPUT,'Proforma agreeement '||v_sub.sub_number||' Cannot be terminated.');
        OE_MSG_PUB.Count_And_Get
               (   p_count     =>      v_msg_count
               ,   p_data      =>      v_msg_data
               );
        FOR i IN 1..v_msg_count LOOP
          fnd_file.put_line(fnd_file.output,oe_msg_pub.get(i,fnd_api.g_false));
        END LOOP;
      ELSE
        fnd_file.put_line(fnd_file.OUTPUT,'Proforma agreeement '||v_sub.sub_number||' has been terminated.');
      END IF;
    END LOOP;
  END terminate_proforma;
END xxah_proforma;

/
