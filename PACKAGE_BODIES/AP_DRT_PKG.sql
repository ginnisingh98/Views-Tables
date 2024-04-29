--------------------------------------------------------
--  DDL for Package Body AP_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_DRT_PKG" AS
/* $Header: apdrtpkb.pls 120.0.12010000.5 2018/06/06 11:15:50 npendeka noship $ */
  l_package varchar2(33) DEFAULT 'AP_DRT_PKG. ';
  --
  --- Implement log writer
  --
  PROCEDURE write_log
    (message       IN         varchar2
	,stage		 IN					varchar2) IS
  BEGIN

				if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
					fnd_log.string(fnd_log.level_procedure,message,stage);
				end if;
  END write_log;
  --
  --- Implement helper procedure add record corresponding to an error/warning/error
  --
/*  PROCEDURE add_to_results
    (person_id       IN         number
	,entity_type	 IN			varchar2
	,status 		 IN			varchar2
	,msgcode		 IN			varchar2
	,msgaplid		 IN			number
    ,result_tbl    	 IN OUT NOCOPY ap_drt_pkg.result_tbl_type) IS
	n number(15);
  begin
	n := result_tbl.count + 1;
    result_tbl(n).person_id := person_id;
    result_tbl(n).entity_type := entity_type;
    result_tbl(n).status := status;
    result_tbl(n).msgcode := msgcode;
	--hr_utility.set_message(msgaplid,msgcode);
    result_tbl(n).msgaplid := msgaplid;
  end add_to_results;
*/
  --
  --- Implement Core AP specific DRC for TCA entity type
  --
  PROCEDURE ap_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'ap_tca_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);


  BEGIN
    -- .....
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');


    --
	---- Check DRC rule# 1
	--
    BEGIN
		--
		--- Check if the party has parital paid/unpaid invoices
		--
      l_count := 0;

      BEGIN

      select 1 into l_count
	  from ap_invoices_all
	  where party_id = p_person_id
	  and nvl(payment_status_flag, 'N') in ('N','P')
	  and rownum = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count :=0;
      END;

      if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'E'
			  ,msgcode => 'AP_UNPAID_INV_EXISTS'
			  ,msgaplid => 200
			  ,result_tbl => result_tbl);
      end if;


    END;
    --
	--- Check DRC rule# 2
	--
    BEGIN
		--
		--- Check if the party has any incomplete/unreconciled payments
		--
      l_count := 0;

      BEGIN

      select 1 into l_count
	  from ap_checks_all
	  where party_id = p_person_id
	  and status_lookup_code not in ('RECONCILED', 'RECONCILED UNACCOUNTED','VOIDED','CLEARED','CLEARED BUT UNACCOUNTED')
	  and rownum = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count :=0;
      END;

      if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'E'
			  ,msgcode => 'AP_UNREC_PMT_EXISTS'
			  ,msgaplid => 200
			  ,result_tbl => result_tbl);
      end if;


    END;
	--
	--- Check DRC rule# 3
	--
    BEGIN
		--
		--- Check if the party has any pending transactions in invoice interface table
		--
      l_count := 0;

      BEGIN

      select 1 into l_count
	  from ap_invoices_interface
	  where vendor_id = (select vendor_id from ap_suppliers where party_id = p_person_id and rownum =1)
	  and nvl(status, 'NEW') <> 'PROCESSED' --bug 28020838
	  and rownum = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count :=0;
      END;

      if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'E'
			  ,msgcode => 'AP_PNDG_INV_INT_EXISTS'
			  ,msgaplid => 200
			  ,result_tbl => result_tbl);
      end if;


    END;
	--
	--- Check DRC rule# 4
	--
    BEGIN
		--
		--- Check if the party has unreconciled refunds
		--
      l_count := 0;
	  -- This is not clear, need to validate

    BEGIN

    select 1 into l_count
	  from ap_checks_all
	  where party_id =p_person_id
	  and status_lookup_code not in ('RECONCILED', 'RECONCILED UNACCOUNTED')
	  and payment_type_flag = 'R'
	  and rownum = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count :=0;
      END;

      if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'E'
			  ,msgcode => 'AP_UNREC_REFUND_PMT_EXISTS'
			  ,msgaplid => 200
			  ,result_tbl => result_tbl);
      end if;


    END;

	--
	--- Check DRC rule# 5
	--
    BEGIN
		--
		--- Check if the party has unaccounted invoices
		--
      l_count := 0;

    BEGIN

    select 1 into l_count
	  from ap_invoices_all ai
          where ai.party_id = p_person_id
	  and exists(select 1 from ap_invoice_distributions_all aid where ai.invoice_id = aid.invoice_id and aid.posted_flag <>'Y')
	  and rownum = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count :=0;
      END;

      if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'E'
			  ,msgcode => 'AP_UNACCOUNTED_DOCUMENTS_DRT'
			  ,msgaplid => 200
			  ,result_tbl => result_tbl);
      end if;


    END;

	--
	--- Check DRC rule# 6
	--
    BEGIN
		--
		--- Check if the party has invoices with attachments
		--
      l_count := 0;

    BEGIN

    select 1 into l_count
	  from fnd_attached_documents
          where entity_name = 'AP_INVOICES' and pk1_value in
	  (select to_char(invoice_id) from ap_invoices_all where party_id = p_person_id ) --bug 28126515
	  and rownum = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count :=0;
      END;

      if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'W'
			  ,msgcode => 'AP_INV_ATTCH_DATA_EXISTS'
			  ,msgaplid => 200
			  ,result_tbl => result_tbl);
      end if;


    END;


  END ap_tca_drc;
END ap_drt_pkg;

/
