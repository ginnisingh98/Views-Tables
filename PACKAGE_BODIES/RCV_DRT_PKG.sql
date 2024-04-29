--------------------------------------------------------
--  DDL for Package Body RCV_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_DRT_PKG" AS
/* $Header: RCVDRTPB.pls 120.0.12010000.2 2018/03/30 05:19:44 gke noship $ */

  g_pkg_name  CONSTANT VARCHAR2(30) := 'RCV_DRT_PKG';

  -- function to get employee name from employee id
  FUNCTION GET_EMPLOYEE_NAME_FROM_ID(
      p_employee_id IN  rcv_headers_interface.employee_id%TYPE
      ) RETURN rcv_headers_interface.employee_name%TYPE IS

  x_employee_name rcv_headers_interface.employee_name%TYPE;
  l_proc_name VARCHAR2(30) := 'GET_EMPLOYEE_NAME_FROM_ID';
  BEGIN

    PER_DRT_PKG.write_log('Entering: ' || g_pkg_name || '.'||l_proc_name, '10');
    PER_DRT_PKG.write_log('employee_id: '|| p_employee_id, '20');

    IF (p_employee_id IS NULL) THEN
      RETURN NULL;
    END IF;

    SELECT full_name
      INTO x_employee_name
      FROM hr_employees
     WHERE employee_id = p_employee_id;

    PER_DRT_PKG.write_log('employee_name: '|| x_employee_name, '30');


     RETURN x_employee_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN TOO_MANY_ROWS THEN
      RETURN NULL;
  END GET_EMPLOYEE_NAME_FROM_ID;

  ---
  --- Procedure: RCV_HR_DRC
  --- For a given HR Person, this procedure will do several validations for receiving tables.
  --- If any validation fails, it will add result to result_tbl with warning / error message.
  --- Otherwise, it will return nothing and the person record can be removed / disabled.
  ---

  PROCEDURE RCV_HR_DRC
    (person_id IN NUMBER,
     result_tbl OUT nocopy per_drt_pkg.result_tbl_type) IS
  l_proc_name VARCHAR2(30) := 'RCV_HR_DRC';
  l_count     NUMBER;
  l_emp_name  rcv_headers_interface.employee_name%TYPE;

  BEGIN
    PER_DRT_PKG.write_log('Entering: ' || g_pkg_name || '.'||l_proc_name, '10');
    PER_DRT_PKG.write_log('person_id: '|| person_id, '20');

    -- Pending Receiving header interface (employee_name, employee_id) for the person
    PER_DRT_PKG.write_log ('Checking RHI for employee_name and employee_id : '|| person_id,'30');

    l_emp_name := GET_EMPLOYEE_NAME_FROM_ID(person_id);

    SELECT Count(1)
      INTO l_count
      FROM rcv_headers_interface
     WHERE employee_name = l_emp_name
        OR employee_id = person_id;

    IF l_count > 0 THEN
      per_drt_pkg.add_to_results(person_id => person_id
  			                        ,entity_type => 'HR'
 			                          ,status => 'W'
 			                          ,msgcode => 'RCV_DRC_INT_EMP_EXISTS'
 			                          ,msgaplid => 201
 			                          ,result_tbl => result_tbl);

    END IF;

    -- Pending Receiving transaction interface (deliver_to_person) for the person
    PER_DRT_PKG.write_log ('Checking RTI for deliver_to_person_name, deliver_to_person_id and employee_id : '|| person_id,'40');

    SELECT Count(1)
      INTO l_count
      FROM rcv_transactions_interface
     WHERE deliver_to_person_name = l_emp_name
        OR deliver_to_person_id = person_id
        OR employee_id = person_id;

    IF l_count > 0 THEN
      per_drt_pkg.add_to_results(person_id => person_id
  			                        ,entity_type => 'HR'
 			                          ,status => 'W'
 			                          ,msgcode => 'RCV_DRC_INT_EMP_EXISTS'
 			                          ,msgaplid => 201
 			                          ,result_tbl => result_tbl);

    END IF;

    PER_DRT_PKG.write_log('Exitting ' || g_pkg_name || '.'||l_proc_name, '50');


  EXCEPTION
  WHEN OTHERS THEN
    PER_DRT_PKG.write_log('Exception ' || SQLERRM || ' in ' || g_pkg_name || '.'||l_proc_name, '60');
    PER_DRT_PKG.write_log('Exitting ' || g_pkg_name || '.'||l_proc_name, '70');
  END RCV_HR_DRC;

  ---
  --- Procedure: RCV_HR_DRC
  --- For a given TCA party, this procedure will do several validations for receiving tables.
  --- If any validation fails, it will add result to result_tbl with warning / error message.
  --- Otherwise, it will return nothing and the TCA party record can be removed / disabled.
  ---
  PROCEDURE RCV_TCA_DRC
    (person_id IN NUMBER,
     result_tbl OUT nocopy per_drt_pkg.result_tbl_type) IS
  l_proc_name VARCHAR2(30) := 'RCV_TCA_DRC';
  l_count     NUMBER;

  BEGIN
    PER_DRT_PKG.write_log('Entering: ' || g_pkg_name || '.'||l_proc_name, '10');
    PER_DRT_PKG.write_log('person_id: '|| person_id, '20');

    -- Pending Shipment supply for the supplier
    PER_DRT_PKG.write_log ('Checking pending SHIPMENT supply for supplier : '|| person_id,'30');

    SELECT Count(ms.supply_source_id)
      INTO l_count
      FROM mtl_supply ms,
           po_headers_all poh,
           ap_suppliers sup
     WHERE ms.supply_type_code = 'SHIPMENT'
       AND ms.po_header_id = poh.po_header_id
       AND poh.vendor_id = sup.vendor_id
       AND sup.party_id = person_id;


    IF l_count > 0 THEN
      per_drt_pkg.add_to_results(person_id => person_id
  			                        ,entity_type => 'TCA'
 			                          ,status => 'E'
 			                          ,msgcode => 'RCV_DRC_MS_EXISTS'
 			                          ,msgaplid => 201
 			                          ,result_tbl => result_tbl);

    END IF;


    -- Pending Receiving supply for the supplier
    PER_DRT_PKG.write_log ('Checking pending RECEIVING supply for supplier : '|| person_id,'40');

    SELECT Count(rs.supply_source_id)
      INTO l_count
      FROM rcv_supply rs,
           po_headers_all poh,
           ap_suppliers sup
     WHERE rs.supply_type_code = 'RECEIVING'
       AND rs.po_header_id = poh.po_header_id
       AND poh.vendor_id = sup.vendor_id
       AND sup.party_id = person_id;

    IF l_count > 0 THEN
      per_drt_pkg.add_to_results(person_id => person_id
  			                        ,entity_type => 'TCA'
 			                          ,status => 'E'
 			                          ,msgcode => 'RCV_DRC_RS_SUP_EXISTS'
 			                          ,msgaplid => 201
 			                          ,result_tbl => result_tbl);

    END IF;


    -- Pending Receiving interface for the supplier
    PER_DRT_PKG.write_log ('Checking pending interface for supplier : '|| person_id,'50');

    SELECT Count(rti.group_id)
      INTO l_count
      FROM rcv_transactions_interface rti,
           po_headers_all poh,
           ap_suppliers sup
     WHERE rti.po_header_id = poh.po_header_id
       AND poh.vendor_id = sup.vendor_id
       AND sup.party_id = person_id;


    IF l_count > 0 THEN
      per_drt_pkg.add_to_results(person_id => person_id
  			                        ,entity_type => 'TCA'
 			                          ,status => 'E'
 			                          ,msgcode => 'RCV_DRC_INT_SUP_EXISTS'
 			                          ,msgaplid => 201
 			                          ,result_tbl => result_tbl);

    END IF;


    -- Pending Receiving supply for the customer
    PER_DRT_PKG.write_log ('Checking pending RECEIVING supply for customer : '|| person_id,'60');

    SELECT Count(rs.supply_source_id)
      INTO l_count
      FROM rcv_supply rs,
           oe_order_headers_all oeh,
           hz_cust_accounts cust
     WHERE rs.supply_type_code = 'RECEIVING'
       AND rs.oe_order_header_id = oeh.header_id
       AND oeh.sold_to_org_id = cust.cust_account_id
       AND cust.party_id = person_id;

    IF l_count > 0 THEN
      per_drt_pkg.add_to_results(person_id => person_id
  			                        ,entity_type => 'TCA'
 			                          ,status => 'E'
 			                          ,msgcode => 'RCV_DRC_RS_CUST_EXISTS'
 			                          ,msgaplid => 201
 			                          ,result_tbl => result_tbl);

    END IF;



    -- Pending Receiving interface for the customer
    PER_DRT_PKG.write_log ('Checking pending interface for customer : '|| person_id,'70');

    SELECT Count(rti.group_id)
      INTO l_count
      FROM rcv_transactions_interface rti,
           oe_order_headers_all oeh,
           hz_cust_accounts cust
     WHERE rti.oe_order_header_id = oeh.header_id
       AND oeh.sold_to_org_id = cust.cust_account_id
       AND cust.party_id = person_id;


    IF l_count > 0 THEN
      per_drt_pkg.add_to_results(person_id => person_id
  			                        ,entity_type => 'TCA'
 			                          ,status => 'E'
 			                          ,msgcode => 'RCV_DRC_INT_CUST_EXISTS'
 			                          ,msgaplid => 201
 			                          ,result_tbl => result_tbl);

    END IF;


    PER_DRT_PKG.write_log('Exitting ' || g_pkg_name || '.'||l_proc_name, '80');

  EXCEPTION
  WHEN OTHERS THEN
    PER_DRT_PKG.write_log('Exception ' || SQLERRM || ' in ' || g_pkg_name || '.'||l_proc_name, '90');
    PER_DRT_PKG.write_log('Exitting ' || g_pkg_name || '.'||l_proc_name, '100');

  END RCV_TCA_DRC;


END RCV_DRT_PKG;

/
