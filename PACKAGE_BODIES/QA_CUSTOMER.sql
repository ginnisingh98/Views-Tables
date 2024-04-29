--------------------------------------------------------
--  DDL for Package Body QA_CUSTOMER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CUSTOMER" AS
/* $Header: qarcb.pls 120.0 2005/05/24 19:11:56 appldev noship $ */

    PROCEDURE merge(
        req_id IN NUMBER,
        set_number IN NUMBER,
        process_mode IN VARCHAR2) IS

        MERGE_NOT_ALLOWED    EXCEPTION;
        CURSOR c IS
            SELECT qr.customer_id
            FROM   qa_results qr, ra_customer_merges m
            WHERE  qr.customer_id = m.duplicate_id AND
                   m.process_flag = 'N' AND
                   m.request_id = req_id AND
                   m.set_number = set_number;

        from_cust_id NUMBER;
	Veto_Reason varchar2(300) := 'During account merge an old customer ID is found in QA_RESULTS table. The table is used to store archival info of test data.  The customer name can be used for auditing purpose and cannot be deleted';

    BEGIN
        arp_message.set_line('QA_CUSTOMER.MERGE()+');

        IF process_mode = 'LOCK' THEN
            null; -- no update will be allowed later
        ELSE
            OPEN c;
            FETCH c INTO from_cust_id;
            IF c%FOUND THEN
                CLOSE c;
/* rkaza. 07/19/2002. Bug 2447495.
QA should only veto the merge delete request.  If just a simple merge w/o
deleting the actual record, QA should simply let it go.
*/
                -- RAISE MERGE_NOT_ALLOWED;
	        ARP_CMERGE_MASTER.veto_delete(
                      req_id            =>        req_id,
                      set_num           =>        set_number,
                      from_customer_id  =>	  from_cust_id,
                      veto_reason       =>	  Veto_Reason
                );
            ELSE
                CLOSE c;
                arp_message.set_name('AR', 'AR_ROWS_UPDATED');
                arp_message.set_token('NUM_ROWS', '0');
            END IF;
        END IF;
        arp_message.set_line('QA_CUSTOMER.MERGE()-');

    EXCEPTION
/*
	WHEN MERGE_NOT_ALLOWED THEN
        arp_message.set_error('QA_CUSTOMER.MERGE');
*/
    WHEN OTHERS THEN
        arp_message.set_error('QA_CUSTOMER.MERGE');
        RAISE;
    END merge;

END qa_customer;

/
