--------------------------------------------------------
--  DDL for Package Body ONT_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_DRT_PKG" AS
 /* $Header: OEDRTUPB.pls 120.0.12010000.4 2018/07/26 21:19:04 gabhatia noship $*/

  l_package varchar2(33) DEFAULT 'ont_drt_pkg.';
  --
  --- Implement log writter
  --
  PROCEDURE write_log
    (message       IN         varchar2
    ,stage		 IN                		varchar2) IS
  BEGIN

    if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
        fnd_log.string(fnd_log.level_procedure,message,stage);
    end if;
   --     oe_debug_pub.ADD(message);   --gabhatia
  END write_log;

  --
  --- Implement Core HR specific DRC for TCA entity type
  --
  PROCEDURE ont_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_proc varchar2(72) := l_package|| 'ont_tca_drc';
    p_person_id number(20);
    n number;
    l_temp varchar2(20);
    l_ord_exists varchar2(20) :='N' ;
    l_agreement_exists varchar2(20) :='N';
    l_iface_exists varchar2(20) :='N';
    l_result_tbl per_drt_pkg.result_tbl_type;


CURSOR  c_contact_person IS
SELECT DISTINCT ACCT_ROLE.cust_account_role_id
FROM hz_cust_account_roles ACCT_ROLE,
     hz_relationships REL
WHERE REL.subject_id = p_person_id       --   HZ_PARTIES.party_id
AND   REL.subject_table_name = 'HZ_PARTIES'
AND   REL.object_table_name = 'HZ_PARTIES'
AND   REL.subject_type = 'PERSON'
AND   REL.party_id = ACCT_ROLE.party_id
AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'    ;

CURSOR c_cust_account IS
  SELECT DISTINCT acct.cust_account_id cust_account_id
  FROM  hz_cust_accounts               acct
  WHERE acct.party_id=  p_person_id;

CURSOR c_site_use_id IS
   SELECT /* MOAC_SQL_CHANGE */  /*+ INDEX(ACCT_SITE,HZ_CUST_ACCT_SITES_N2) */   SITE.SITE_USE_ID  ,SITE.SITE_USE_CODE
    FROM HZ_CUST_ACCT_SITES_all     ACCT_SITE,
        HZ_CUST_SITE_USES_ALL      SITE,
        HZ_CUST_ACCOUNTS      CUST_ACCT
    WHERE CUST_ACCT.PARTY_ID=  p_person_id
    AND ACCT_SITE.CUST_ACCOUNT_ID=CUST_ACCT.CUST_ACCOUNT_ID
    AND SITE.CUST_ACCT_SITE_ID     = ACCT_SITE.CUST_ACCT_SITE_ID
    AND SITE.SITE_USE_CODE IN ('BILL_TO' , 'SHIP_TO') ;   --'DELIVER_TO' not used as of now for perfromance reasons


  BEGIN

    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
    --

   ------check is person is used in for sold_to Or end_customer in OM entities---------
    write_log ('before c_cust_account : '|| p_person_id,'30');

      FOR c_cust IN c_cust_account  LOOP

     IF (l_ord_exists='N') THEN
     write_log ('check orders in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'31');
      BEGIN
          SELECT 'Yes'
          INTO l_ord_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_order_headers_all
                         WHERE  open_flag ='Y'
                          AND   (     ( sold_to_org_id =    c_cust.cust_account_id )
                              --    OR  ( end_customer_id =   c_cust.cust_account_id )
                                )
                        )   ;

        write_log ('    *Found orders in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'31');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_ORDERS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

      EXCEPTION
        WHEN no_data_found THEN
         NULL;         --no records on OEOL ,check other entities
      END;
     END IF ; --l_ord_exists

--28304918: since sold_to_org_id will be same on header and line , no need to check oeol
-- 28304918 : commenting below check.
/*
     IF (l_ord_exists='N') THEN
     write_log ('check order lines in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'31');
      BEGIN
          SELECT 'Yes'
          INTO l_ord_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_order_lines_all
                         WHERE  open_flag ='Y'
                          AND   (     ( sold_to_org_id =    c_cust.cust_account_id )
                              --    OR  ( end_customer_id =   c_cust.cust_account_id )
                                )
                        )   ;

        write_log ('    *Found order lines in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'31');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_ORDERS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

      EXCEPTION
        WHEN no_data_found THEN
         NULL;         --no records on OEOL ,check other entities
      END;
     END IF ; --l_ord_exists
*/--end 28304918

 ---
   IF (l_agreement_exists ='N') THEN
          write_log ('check Agreements in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'33');
     BEGIN
          SELECT 'Yes'
          INTO l_agreement_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_blanket_headers_all
                         WHERE  open_flag ='Y'
                          AND   sold_to_org_id = c_cust.cust_account_id ) ;

            write_log ('    *Found Agreements in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'33');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_AGREEMENTS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF ; --l_agreement_exists

--28304918: since sold_to_org_id will be same on header and line , no need to check at line level
-- 28304918 : commenting below check.
/*

   IF (l_agreement_exists ='N') THEN
          write_log ('check Agreement lines in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'33');
     BEGIN
          SELECT 'Yes'
          INTO l_agreement_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_blanket_lines_all
                         WHERE  open_flag ='Y'
                          AND   sold_to_org_id = c_cust.cust_account_id ) ;

            write_log ('    *Found Agreement lines in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'33');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_AGREEMENTS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF ; --l_agreement_exists
*/--end 28304918

 ---
 IF (l_iface_exists ='N' ) THEN
          write_log ('check OM Interface table in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'35');
     BEGIN
          SELECT 'Yes'
          INTO l_iface_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM OE_HEADERS_IFACE_ALL
                         WHERE  (     ( sold_to_org_id =    c_cust.cust_account_id )
                              --    OR  ( end_customer_id =   c_cust.cust_account_id )
                                )
                                )  ;
               write_log ('    *FOund OM Interface table in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'35');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_IFACE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
END IF ;-- IF (l_iface_exists ='N' ) THEN

 IF (l_iface_exists ='N' ) THEN
          write_log ('check OM Interface lines table in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'35');
     BEGIN
          SELECT 'Yes'
          INTO l_iface_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM OE_LINES_IFACE_ALL
                         WHERE  (     ( sold_to_org_id =    c_cust.cust_account_id )
                              --    OR  ( end_customer_id =   c_cust.cust_account_id )
                                )
                                )  ;
               write_log ('    *FOund OM Interface Lines table in  c_cust_account cust_account_id: '|| c_cust.cust_account_id,'35');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_IFACE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
END IF ;-- IF (l_iface_exists ='N' ) THEN

END LOOP ;     --c_cust_account
     write_log ('After c_cust_account : '|| p_person_id,'40');

----------------
      write_log ('Before c_site_use_id : '|| p_person_id,'40');

 FOR c_site IN c_site_use_id  LOOP

     IF ( ( l_ord_exists = 'Yes' ) AND ( l_agreement_exists ='Yes') AND ( l_iface_exists =  'Yes') ) THEN
          write_log ('**Person found in all three entities(orders, agreements, interfce) , no need to check sites further: ','41');
         EXIT;
     END IF ;

     write_log ('check  in  c_site_use_id SITE_USE_ID: '|| c_site.SITE_USE_ID,'41');
     write_log ('check   in  c_site_use_id SITE_USE_CODE: '|| c_site.SITE_USE_CODE,'41');

  IF c_site.SITE_USE_CODE  ='BILL_TO' THEN

   IF (l_ord_exists='N') THEN
           write_log ('check Orders' ,'41');
    BEGIN
          SELECT 'Yes'
          INTO l_ord_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_order_headers_all
                         WHERE  open_flag ='Y'
                          AND   invoice_to_org_id =   c_site.SITE_USE_ID)    ;

      write_log ('    *Found  in  c_site_use_id SITE_USE_ID: '|| c_site.SITE_USE_ID,'41');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_ORDERS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on OEOL ,check other entities
    END;
  END IF ;--     IF (l_ord_exists='N') THEN


     IF (l_ord_exists='N') THEN
           write_log ('check Order Lines' ,'41');
    BEGIN
          SELECT 'Yes'
          INTO l_ord_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_order_lines_all
                         WHERE  open_flag ='Y'
                          AND   invoice_to_org_id =   c_site.SITE_USE_ID)    ;

      write_log ('    *Found  in  c_site_use_id SITE_USE_ID: '|| c_site.SITE_USE_ID,'41');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_ORDERS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on OEOL ,check other entities
    END;
  END IF ;--     IF (l_ord_exists='N') THEN
 ---
   IF (l_agreement_exists ='N') THEN
          write_log ('check Agreements' ,'43');
     BEGIN
          SELECT 'Yes'
          INTO l_agreement_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_blanket_headers_all
                         WHERE  open_flag ='Y'
                          AND   invoice_to_org_id =   c_site.SITE_USE_ID) ;

          write_log ('    *Found Agreements' ,'43');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_AGREEMENTS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
 END IF ; --   IF (l_agreement_exists ='N') THEN

   IF (l_agreement_exists ='N') THEN
          write_log ('check Agreement Lines' ,'43');
     BEGIN
          SELECT 'Yes'
          INTO l_agreement_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_blanket_Lines_all
                         WHERE  open_flag ='Y'
                          AND   invoice_to_org_id =   c_site.SITE_USE_ID) ;

          write_log ('    *Found Agreements' ,'43');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_AGREEMENTS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
 END IF ; --   IF (l_agreement_exists ='N') THEN


 ---
  IF (l_iface_exists ='N' ) THEN
          write_log ('check OM Interface table ','45');

     BEGIN
          SELECT 'Yes'
          INTO l_iface_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM OE_HEADERS_IFACE_ALL
                         WHERE invoice_to_org_id =   c_site.SITE_USE_ID
                                )  ;
                    write_log ('    *Found OM Interface table ','45');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'W'
                ,msgcode => 'OE_PERSON_OPEN_IFACE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
    END IF ;-- IF (l_iface_exists ='N' ) THEN

    IF (l_iface_exists ='N' ) THEN
          write_log ('check OM Interface Lines table ','45');

     BEGIN
          SELECT 'Yes'
          INTO l_iface_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM OE_LINES_IFACE_ALL
                         WHERE invoice_to_org_id =   c_site.SITE_USE_ID
                                )  ;
                    write_log ('    *Found OM Interface table ','45');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'W'
                ,msgcode => 'OE_PERSON_OPEN_IFACE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
    END IF ;-- IF (l_iface_exists ='N' ) THEN

 END IF ; --'BILL_TO'

  --------  check for ship_to and intermediate_ship_to

    IF c_site.SITE_USE_CODE  ='SHIP_TO' THEN

   IF (l_ord_exists='N') THEN
          write_log ('check Orders' ,'51');
     BEGIN
          SELECT 'Yes'
          INTO l_ord_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_order_headers_all
                         WHERE  open_flag ='Y'
                          AND   ship_to_org_id =   c_site.SITE_USE_ID);
            write_log ('    *Found Orders' ,'51');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_ORDERS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on OEOL ,check other entities
    END;
  END IF;--   IF (l_ord_exists='N') THEN

     IF (l_ord_exists='N') THEN
          write_log ('check Order Lines' ,'51');
     BEGIN
          SELECT 'Yes'
          INTO l_ord_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_order_lines_all
                         WHERE  open_flag ='Y'
                           AND  ( ship_to_org_id =   c_site.SITE_USE_ID
                              --    OR    intmed_ship_to_org_id =c_site.SITE_USE_ID
                                  )
                       );
            write_log ('    *Found Order Lines' ,'51');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_ORDERS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on OEOL ,check other entities
    END;
  END IF;--   IF (l_ord_exists='N') THEN

 ---

   IF (l_agreement_exists ='N') THEN
          write_log ('check Agreements' ,'53');
     BEGIN
          SELECT 'Yes'
          INTO l_agreement_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_blanket_headers_all
                         WHERE  open_flag ='Y'
                          AND   ship_to_org_id =   c_site.SITE_USE_ID) ;

                 write_log ('    *FOund Agreements' ,'53');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_AGREEMENTS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF; --   IF (l_agreement_exists ='N') THEN

   IF (l_agreement_exists ='N') THEN
          write_log ('check Agreement Lines' ,'53');
     BEGIN
          SELECT 'Yes'
          INTO l_agreement_exists
          FROM dual
          WHERE EXISTS  ( SELECT 1 FROM oe_blanket_lines_all
                         WHERE  open_flag ='Y'
                          AND    ( ship_to_org_id =   c_site.SITE_USE_ID
                       --           OR    intmed_ship_to_org_id =c_site.SITE_USE_ID
                                  )
                         ) ;

                 write_log ('    *FOund Agreement Lines' ,'53');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_AGREEMENTS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF; --   IF (l_agreement_exists ='N') THEN

 ---

 IF (l_iface_exists ='N' ) THEN
          write_log ('check OM Interface table ','55');
     BEGIN
          SELECT 'Yes'
          INTO l_iface_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM OE_HEADERS_IFACE_ALL
                         WHERE ship_to_org_id =   c_site.SITE_USE_ID
                                ) ;

          write_log ('    *Found OM Interface table ','55');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_IFACE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF; -- IF (l_iface_exists ='N' ) THEN

  IF (l_iface_exists ='N' ) THEN
          write_log ('check OM Interface Lines table ','55');
     BEGIN
          SELECT 'Yes'
          INTO l_iface_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM OE_LINES_IFACE_ALL
                         WHERE ship_to_org_id =   c_site.SITE_USE_ID
                                ) ;

          write_log ('    *Found OM Interface Lines table ','55');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_IFACE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF; -- IF (l_iface_exists ='N' ) THEN

 END IF ; --'SHIP_TO'
  ---------end--ship_to--------


  --------Deliver_to-----------

  /*
  IF c_site.SITE_USE_CODE  ='DELIVER_TO' THEN

    IF (l_ord_exists='N') THEN
           write_log ('check Orders' ,'61');
     BEGIN
          SELECT 'Yes'
          INTO l_ord_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_order_headers_all
                         WHERE  open_flag ='Y'
                          AND   deliver_to_org_id =   c_site.SITE_USE_ID)
             OR EXISTS ( SELECT 1 FROM oe_order_lines_all
                         WHERE  open_flag ='Y'
                           AND  deliver_to_org_id =   c_site.SITE_USE_ID
                       );

           write_log ('    *Found Orders' ,'61');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_ORDERS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on OEOL ,check other entities
    END;
  END IF; --l_ord_exists
 ---

   IF (l_agreement_exists ='N') THEN
          write_log ('check Agreements' ,'63');
     BEGIN
          SELECT 'Yes'
          INTO l_agreement_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_blanket_headers_all
                         WHERE  open_flag ='Y'
                          AND   deliver_to_org_id =   c_site.SITE_USE_ID)
            OR  EXISTS ( SELECT 1 FROM oe_blanket_lines_all
                         WHERE  open_flag ='Y'
                          AND   deliver_to_org_id =   c_site.SITE_USE_ID ) ;

                              write_log ('    *Found Agreements' ,'63');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_PERSON_OPEN_AGREEMENTS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF ; --   IF (l_agreement_exists ='N') THEN


 ---

 IF (l_iface_exists ='N' ) THEN
          write_log ('check OM Interface table ','65');
     BEGIN
          SELECT 'Yes'
          INTO l_iface_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM OE_HEADERS_IFACE_ALL
                         WHERE deliver_to_org_id =   c_site.SITE_USE_ID
                                )
              OR EXISTS ( SELECT 1 FROM OE_LINES_IFACE_ALL
                         WHERE  deliver_to_org_id =   c_site.SITE_USE_ID
                        );

                               write_log ('    *FOund OM Interface table ','65');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'W'
                ,msgcode => 'OE_PERSON_OPEN_IFACE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF ; -- IF (l_iface_exists ='N' ) THEN

 END IF ; --'DELIVER_TO'

    */
  -------end Deliver To--------

END LOOP ;     --end loop c_site_use_id
     write_log ('After c_site_use_id : '|| p_person_id,'70');



---------------- Contacts-------

/*
      write_log ('Before  c_contact_person : '|| p_person_id,'70');

  FOR c_contacts IN c_contact_person LOOP
                   --CUST_ACCOUNT_ROLE_ID

       IF (l_ord_exists='N') THEN
       write_log ('check orders in  c_contacts CUST_ACCOUNT_ROLE_ID: '|| c_contacts.CUST_ACCOUNT_ROLE_ID,'71');
       BEGIN
          SELECT 'Yes'
          INTO l_ord_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_order_headers_all
                         WHERE  open_flag ='Y'
                          AND   (     ( sold_to_contact_id =    c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( invoice_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( deliver_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( ship_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( end_customer_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                )
                        )
            OR  EXISTS ( SELECT 1 FROM oe_order_lines_all
                         WHERE  open_flag ='Y'
                           AND   (    ( invoice_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( deliver_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( ship_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( end_customer_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( INTMED_SHIP_TO_CONTACT_ID =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                )
                        );

               write_log ('    *Found Orders CUST_ACCOUNT_ROLE_ID: '|| c_contacts.CUST_ACCOUNT_ROLE_ID,'72');

        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_CONTACT_OPEN_ORDERS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on OEOL ,check other entities
    END;
    END IF; --   IF (l_ord_exists='N') THEN

 ---
   IF (l_agreement_exists ='N') THEN
          write_log ('check Agreements c_contacts CUST_ACCOUNT_ROLE_ID: '|| c_contacts.CUST_ACCOUNT_ROLE_ID,'73');
     BEGIN
          SELECT 'Yes'
          INTO l_agreement_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM oe_blanket_headers_all
                         WHERE  open_flag ='Y'
                           AND   (     ( sold_to_contact_id =    c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( invoice_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( deliver_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( ship_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                )
                              )
           OR EXISTS ( SELECT 1 FROM oe_blanket_lines_all
                         WHERE  open_flag ='Y'
                           AND   (   ( invoice_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( deliver_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( ship_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                  OR  ( INTMED_SHIP_TO_CONTACT_ID =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                )
                        ) ;
            write_log ('    *Found Agreements CUST_ACCOUNT_ROLE_ID: '|| c_contacts.CUST_ACCOUNT_ROLE_ID,'73');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'E'
                ,msgcode => 'OE_CONTACT_OPEN_AGREEMENTS'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF ;     --   IF (l_agreement_exists ='N') THEN



 ---

 IF (l_iface_exists ='N' ) THEN
          write_log ('check OM Interface table c_contacts CUST_ACCOUNT_ROLE_ID: '|| c_contacts.CUST_ACCOUNT_ROLE_ID,'75');
     BEGIN
          SELECT 'Yes'
          INTO l_iface_exists
          FROM dual
          WHERE EXISTS ( SELECT 1 FROM OE_HEADERS_IFACE_ALL
                         WHERE (     ( sold_to_contact_id =    c_contacts.CUST_ACCOUNT_ROLE_ID )
                                    OR  ( invoice_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                    OR  ( deliver_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                    OR  ( ship_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                    OR  ( end_customer_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                 )
                        )
               OR EXISTS ( SELECT 1 FROM OE_LINES_IFACE_ALL
                         WHERE  (        ( invoice_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                      OR  ( deliver_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                      OR  ( ship_to_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                      OR  ( end_customer_contact_id =   c_contacts.CUST_ACCOUNT_ROLE_ID )
                                    )
                         );
            write_log ('    *Found OM Interface table c_contacts CUST_ACCOUNT_ROLE_ID: '|| c_contacts.CUST_ACCOUNT_ROLE_ID,'76');


        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'W'
                ,msgcode => 'OE_CONTACT_OPEN_IFACE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

   EXCEPTION
    WHEN no_data_found THEN
      NULL;         --no records on Agreemnet lines ,check other entities
    END;
  END IF ;  -- IF (l_iface_exists ='N' ) THEN

  END LOOP ; --c_contact_person
       write_log ('After  c_contact_person : '|| p_person_id,'80');
    */
----------------


    --
    IF result_tbl.count < 1 THEN         --gabhatia required if success..
                per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'TCA'
                ,status => 'S'
                ,msgcode => null
                ,msgaplid => 660
                ,result_tbl => result_tbl);
    END IF;
    write_log ('Leaving: '|| l_proc,'90');

  END ont_tca_drc;
    --
  --- Implement Core HR specific DRC for FND entity type
  --
  PROCEDURE ont_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_proc varchar2(72) := l_package|| 'ont_fnd_drc';
    p_person_id number(20);
    n number;
    l_temp varchar2(20);
    l_result_tbl per_drt_pkg.result_tbl_type;
    l_user_name VARCHAR2(100) ;

  CURSOR c_feedback_profile IS
  SELECT DISTINCT  f.PROFILE_OPTION_VALUE
                FROM FND_PROFILE_OPTION_VALUES f,
                     FND_PROFILE_OPTIONS l
               where  l.PROFILE_OPTION_ID = f.PROFILE_OPTION_ID
               AND   l.profile_option_name IN(  'ONT_FEEDBACK_PROFILE'   )
               AND  f.application_id =660 ;  --bug 28208880


  CURSOR c_reportdefect_profile IS
  SELECT DISTINCT  f.PROFILE_OPTION_VALUE
                FROM FND_PROFILE_OPTION_VALUES f,
                     FND_PROFILE_OPTIONS l
               where  l.PROFILE_OPTION_ID = f.PROFILE_OPTION_ID
               AND   l.profile_option_name IN('ONT_REPORTDEFECT_PROFILE' )
               AND  f.application_id =660 ;--bug 28208880


  CURSOR c_notif_profile IS
  SELECT DISTINCT  f.PROFILE_OPTION_VALUE
                FROM FND_PROFILE_OPTION_VALUES f,
                     FND_PROFILE_OPTIONS l
               where  l.PROFILE_OPTION_ID = f.PROFILE_OPTION_ID
               AND   l.profile_option_name IN('OE_NOTIFICATION_APPROVER' )
               AND  f.application_id =660 ;--bug 28208880


CURSOR c_wf_role IS
    SELECT w.name
      FROM wf_roles   w
     WHERE w.orig_system   ='FND_USR'
       AND w.orig_system_id  = p_person_id;

  BEGIN

    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
	--
	--- PER and SSHR does not use FND User ID anywhere so no DRC rules
	--- If any product uses FND User ID then DRCs need to be written here */

  BEGIN
       write_log ('Query for user_name: '|| p_person_id,'30');

        SELECT user_name
        INTO l_user_name
        from fnd_user
        WHERE user_id =   p_person_id
        AND customer_id IS NULL
        AND supplier_id IS NULL ;

     write_log ('Check for l_user_name: '|| l_user_name,'30');

          FOR c1 IN c_feedback_profile LOOP
            write_log ('    c1.PROFILE_OPTION_VALUE : '|| c1.PROFILE_OPTION_VALUE,'31');
           IF  c1.PROFILE_OPTION_VALUE = l_user_name THEN

                per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'FND'
                ,status => 'E'
                ,msgcode => 'OE_SET_FEEDBACK_PROFILE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

                EXIT;
           END IF;
          END LOOP ;
----
      write_log ('l_user_name: '|| l_user_name,'40');

          FOR c2 IN c_reportdefect_profile LOOP
            write_log ('    c2.PROFILE_OPTION_VALUE: '|| c2.PROFILE_OPTION_VALUE,'41');
           IF  c2.PROFILE_OPTION_VALUE = l_user_name THEN

                per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'FND'
                ,status => 'E'
                ,msgcode => 'OE_SET_REPORT_DEFECT_PROFILE'
                ,msgaplid => 660
                ,result_tbl => result_tbl);

                EXIT;
           END IF;
          END LOOP ;

    EXCEPTION
    WHEN no_data_found THEN
             write_log ('no fnd_usr with customer_id and supplier_id null ' ,'45');         --
    END;

 ----
      write_log ('check c_wf_role: ','50');


              FOR c_role IN c_wf_role LOOP

                write_log ('    checking notif profile and appriver table for  c_role: ' || c_role.name ,'51');
                --check role name in notif profile
                     FOR c3 IN c_notif_profile LOOP
                        IF  c3.PROFILE_OPTION_VALUE = c_role.name THEN

                         write_log ('    Found Profile set for c_role: ' || c_role.name ,'52');

                              per_drt_pkg.add_to_results
                              (person_id => p_person_id
                              ,entity_type => 'FND'
                              ,status => 'E'
                              ,msgcode => 'OE_SET_APPROVER_PROFILE'
                              ,msgaplid => 660
                              ,result_tbl => result_tbl);

                              EXIT;
                        END IF;
                     END LOOP ;--c_notif_profile

               --check role name in oe_approver_list-members table
                    write_log ('    *check role name in oe_approver_list_members table' ,'53');

                  BEGIN
                        SELECT 'Yes'
                        INTO l_temp
                        FROM dual
                        WHERE EXISTS ( SELECT 1 FROM OE_APPROVER_LIST_MEMBERS
                                        WHERE  ROLE = c_role.name
                                          AND  active_flag ='Y'
                                      );

                       write_log ('    *found role name in oe_approver_list_members table' ,'54');


                      per_drt_pkg.add_to_results
                      (person_id => p_person_id
                              ,entity_type => 'FND'
                              ,status => 'E'
                              ,msgcode => 'OE_UPDATE_TRANSACTION_APPROVER'
                              ,msgaplid => 660
                              ,result_tbl => result_tbl);
                      EXIT;
                EXCEPTION
                  WHEN no_data_found THEN
                    NULL;         --no records on Agreemnet lines ,check other entities
                  END;


              END LOOP;   --c_wf_role

       write_log ('After c_wf_role: ','60');

    --
    IF result_tbl.count < 1 THEN
        per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'FND'
                ,status => 'S'
                ,msgcode => NULL
                ,msgaplid => 660
                ,result_tbl => result_tbl);
    END IF;
    write_log ('Leaving: '|| l_proc,'80');

  END ont_fnd_drc;

  --
  --- Implement Core HR specific DRC for HR entity type
  --
  PROCEDURE ont_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'ont_hr_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);

  CURSOR c_notif_profile IS
  SELECT DISTINCT  f.PROFILE_OPTION_VALUE
                FROM FND_PROFILE_OPTION_VALUES f,
                     FND_PROFILE_OPTIONS l
               where  l.PROFILE_OPTION_ID = f.PROFILE_OPTION_ID
               AND   l.profile_option_name IN('OE_NOTIFICATION_APPROVER' )
               AND  f.application_id =660 ;--bug 28208880


CURSOR c_wf_role IS
    SELECT w.name
      FROM wf_roles   w
     WHERE w.orig_system   ='PER'
       AND w.orig_system_id  = p_person_id;

  BEGIN

    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
    --
	---- Check DRC rule# 1
	--
      write_log ('Check c_wf_role: ','20');


              FOR c_role IN c_wf_role LOOP

                write_log ('    +Check for role_name c_role: ' || c_role.name ,'21');
                --check role name in notif profile
                     FOR c3 IN c_notif_profile LOOP
                        IF  c3.PROFILE_OPTION_VALUE = c_role.name THEN

                         write_log ('    +Found role name in profile c_role: ' || c_role.name ,'22');

                              per_drt_pkg.add_to_results
                              (person_id => p_person_id
                              ,entity_type => 'HR'
                              ,status => 'E'
                              ,msgcode => 'OE_SET_APPROVER_PROFILE'
                              ,msgaplid => 660
                              ,result_tbl => result_tbl);

                              EXIT;
                        END IF;
                     END LOOP ;--c_notif_profile

               --check role name in oe_approver_list-members table
                    write_log ('    *Check role name in oe_approver_list_members table c_role: ' || c_role.name ,'23');

                  BEGIN
                        SELECT 'Yes'
                        INTO l_temp
                        FROM dual
                        WHERE EXISTS ( SELECT 1 FROM OE_APPROVER_LIST_MEMBERS
                                        WHERE  ROLE = c_role.name
                                          AND  active_flag ='Y'
                                      );

                       write_log ('    *Found role name in oe_approver_list_members table' ,'24');


                      per_drt_pkg.add_to_results
                      (person_id => p_person_id
                              ,entity_type => 'HR'
                              ,status => 'E'
                              ,msgcode => 'OE_UPDATE_TRANSACTION_APPROVER'
                              ,msgaplid => 660
                              ,result_tbl => result_tbl);
                       EXIT;
                EXCEPTION
                  WHEN no_data_found THEN
                    NULL;         --no records on Agreemnet lines ,check other entities
                  END;


              END LOOP;   --c_wf_role

       write_log ('After c_wf_role: ','30');

    --
    IF result_tbl.count < 1 THEN
    	per_drt_pkg.add_to_results
                (person_id => p_person_id
                ,entity_type => 'HR'
                ,status => 'S'
                ,msgcode => null
                ,msgaplid => 660
                ,result_tbl => result_tbl);
    END IF;
    write_log ('Leaving: '|| l_proc,'80');



  END ont_hr_drc;

PROCEDURE ont_fnd_pre
    (person_id       IN         number ) IS

    l_proc varchar2(72) := l_package|| 'ont_fnd_pre';
    p_person_id number(20);

    l_res boolean;
    l_profile_name VARCHAR2(80);
    l_profile_option_value  VARCHAR2(240):='NA';
    l_user_name  VARCHAR2(320);
    l_role_name  VARCHAR2(320);

    CURSOR c_update_profile IS
    SELECT  pov.profile_option_value   ,
            decode(pov.level_id,  10001,'SITE'  ,10002,'APPL', 10003,'RESP', 10004,'USER') level_id,
            pov.level_value ,
            pov.level_value_application_id
    FROM
    fnd_profile_option_values pov,
    fnd_profile_options pro
    WHERE pro.profile_option_id = pov.profile_option_id
    AND upper(pro.profile_option_name) = l_profile_name
    AND  pov.profile_option_value = l_user_name
    AND  pov.application_id =660;--bug 28208880

    CURSOR c_wf_role IS
        SELECT w.name  ,w.EXPIRATION_DATE
          FROM wf_local_roles   w
        WHERE w.orig_system   ='FND_USR'
          AND w.orig_system_id  = p_person_id ;
BEGIN
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');

    BEGIN
       write_log ('Query for user_id: '|| p_person_id,'30');

        SELECT user_name
        INTO l_user_name
        from fnd_user
        WHERE user_id =   p_person_id
        AND ( customer_id IS NOT  NULL
             OR  supplier_id IS NOT NULL
             ) ;

     write_log ('Check for l_user_name: '|| l_user_name,'30');

          l_profile_name:=  'ONT_FEEDBACK_PROFILE';
          write_log ('Check for profile: '|| l_profile_name,'30');

          FOR c1 IN c_update_profile LOOP
            write_log ('    c1.PROFILE_OPTION_VALUE : '|| c1.PROFILE_OPTION_VALUE,'31');

--           IF  c1.PROFILE_OPTION_VALUE = l_user_name THEN
               write_log ('    updating profile to null, level_id : '|| c1.level_id,'31');
               write_log ('    profile level that was updated : '|| c1.level_value,'31');

              l_res := FND_PROFILE.SAVE(l_profile_name, null, c1.level_id , c1.level_value,c1.level_value_application_id);

              IF l_res THEN
                   write_log ('    *profile updated to null  ' ,'32');
              ELSE
                   write_log ('    *profile update failed','32');      --raise error?
              END IF;
  --         END IF;
          END LOOP ;

--------
          l_profile_name:=  'ONT_REPORTDEFECT_PROFILE';
          write_log ('Check for profile: '|| l_profile_name,'40');

          FOR c2 IN c_update_profile LOOP
            write_log ('    c2.PROFILE_OPTION_VALUE : '|| c2.PROFILE_OPTION_VALUE,'41');

  --         IF  c2.PROFILE_OPTION_VALUE = l_user_name THEN
               write_log ('    updating profile to null, level_id : '|| c2.level_id,'41');
               write_log ('    profile level that was updated : '|| c2.level_value,'41');

              l_res := FND_PROFILE.SAVE(l_profile_name, null, c2.level_id , c2.level_value ,c2.level_value_application_id);

              IF l_res THEN
                   write_log ('    *profile updated to null  ' ,'42');
              ELSE
                   write_log ('    *profile update failed','42');      --raise error?
              END IF;
 --          END IF;
          END LOOP ;

----
      write_log ('done with profiles for l_user_name: '|| l_user_name,'50');


    EXCEPTION
    WHEN no_data_found THEN
             write_log ('no fnd_usr with customer_id or supplier_id not null ' ,'55');         --
    END;

 ----

       write_log ('check for roles '|| l_user_name,'60');
              FOR c_role IN c_wf_role LOOP

                write_log ('    +Check for role_name c_role: ' || c_role.name ||'    +EXPIRATION_DATE: ' || c_role.EXPIRATION_DATE ,'61');

                IF (c_role.EXPIRATION_DATE is NOT NULL) THEN
                --check role name in notif profile
                      l_profile_name:=  'OE_NOTIFICATION_APPROVER';
                      l_user_name :=  c_role.name;
                      write_log ('Check for profile: '|| l_profile_name,'62');

                      FOR c3 IN c_update_profile LOOP
                        write_log ('    c3.PROFILE_OPTION_VALUE : '|| c3.PROFILE_OPTION_VALUE,'63');
                          write_log ('    updating profile to null, level_id : '|| c3.level_id,'64');
                          write_log ('    profile level that was updated : '|| c3.level_value,'64');

                          l_res := FND_PROFILE.SAVE(l_profile_name, null, c3.level_id , c3.level_value ,c3.level_value_application_id);

                          IF l_res THEN
                              write_log ('    *profile updated to null  ' ,'65');
                          ELSE
                              write_log ('    *profile update failed','65');      --raise error?
                          END IF;
                      END LOOP ;
                   END IF ; --c_role.EXPIRATION_DATE is not null

               --check role name in oe_approver_list-members table
                    write_log ('    *Check role name in oe_approver_list_members table c_role: ' || c_role.name ,'70');

                    l_role_name :=   Dbms_Random.string('a',length (trim ( c_role.name)));

                        UPDATE OE_APPROVER_LIST_MEMBERS
                           SET ROLE = l_role_name --Dbms_Random.string('l',6)
                         WHERE  ROLE = c_role.name;

                       write_log ('    *Found role name in oe_approver_list_members table ' || SQL%ROWCOUNT,'71');


                        UPDATE OE_APPROVER_TRANSACTIONS
                           SET ROLE = l_role_name --Dbms_Random.string('l',8)
                         WHERE  ROLE = c_role.name;

                        write_log ('    *Found role name in OE_APPROVER_TRANSACTIONS table ' || SQL%ROWCOUNT,'71');

              END LOOP;   --c_wf_role

       write_log ('After c_wf_role: ','80');


    write_log ('Leaving: '|| l_proc,'90');

END ont_fnd_pre;



PROCEDURE ont_hr_pre
    (person_id       IN         number ) IS


    l_proc varchar2(72) := l_package|| 'ont_hr_pre';
    p_person_id number(20);

    l_res boolean;
    l_profile_name VARCHAR2(80);
    l_profile_option_value  VARCHAR2(240):='NA';
    l_user_name  VARCHAR2(100);
    l_role_name  VARCHAR2(320);

CURSOR c_update_profile IS
SELECT  pov.profile_option_value   ,
        decode(pov.level_id,  10001,'SITE'  ,10002,'APPL', 10003,'RESP', 10004,'USER') level_id,
        pov.level_value    ,
        pov.level_value_application_id
FROM
fnd_profile_option_values pov,
fnd_profile_options pro
WHERE pro.profile_option_id = pov.profile_option_id
AND upper(pro.profile_option_name) = l_profile_name
AND  pov.profile_option_value = l_role_name
AND  pov.application_id =660;--bug 28208880


CURSOR c_wf_role IS
        SELECT w.name  ,w.EXPIRATION_DATE
          FROM wf_local_roles   w
        WHERE w.orig_system   ='PER'
          AND w.orig_system_id  = p_person_id ;


BEGIN
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');

       write_log ('check for roles '|| l_user_name,'60');
              FOR c_role IN c_wf_role LOOP

                write_log ('    +Check for role_name c_role: ' || c_role.name ||'    +EXPIRATION_DATE: ' || c_role.EXPIRATION_DATE ,'61');

                IF (c_role.EXPIRATION_DATE is NOT NULL) THEN
                --check role name in notif profile
                      l_profile_name:=  'OE_NOTIFICATION_APPROVER';
                      l_user_name :=  c_role.name;
                      write_log ('Check for profile: '|| l_profile_name,'62');

                      FOR c3 IN c_update_profile LOOP
                        write_log ('    c3.PROFILE_OPTION_VALUE : '|| c3.PROFILE_OPTION_VALUE,'63');
                          write_log ('    updating profile to null, level_id : '|| c3.level_id,'64');
                          write_log ('    profile level that was updated : '|| c3.level_value,'64');

                          l_res := FND_PROFILE.SAVE(l_profile_name, null, c3.level_id , c3.level_value ,c3.level_value_application_id);

                          IF l_res THEN
                              write_log ('    *profile updated to null  ' ,'65');
                          ELSE
                              write_log ('    *profile update failed','65');      --raise error?
                          END IF;
                      END LOOP ;
                   END IF ; --c_role.EXPIRATION_DATE is not null

               --check role name in oe_approver_list-members table
                    write_log ('    *Check role name in oe_approver_list_members table c_role: ' || c_role.name ,'70');

                    l_role_name :=   Dbms_Random.string('a',length (trim ( c_role.name)));

                        UPDATE OE_APPROVER_LIST_MEMBERS
                           SET ROLE = l_role_name --Dbms_Random.string('l',6)
                         WHERE  ROLE = c_role.name;

                       write_log ('    *Found role name in oe_approver_list_members table ' || SQL%ROWCOUNT,'71');


                        UPDATE OE_APPROVER_TRANSACTIONS
                           SET ROLE = l_role_name --Dbms_Random.string('l',8)
                         WHERE  ROLE = c_role.name;

                        write_log ('    *Found role name in OE_APPROVER_TRANSACTIONS table ' || SQL%ROWCOUNT,'71');

              END LOOP;   --c_wf_role

       write_log ('After c_wf_role: ','30');



    write_log ('Leaving: '|| l_proc,'80');

END ont_hr_pre;

END ont_drt_pkg;

/
