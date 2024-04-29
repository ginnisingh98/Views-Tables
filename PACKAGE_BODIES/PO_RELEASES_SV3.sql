--------------------------------------------------------
--  DDL for Package Body PO_RELEASES_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELEASES_SV3" as
/* $Header: POXPOR3B.pls 115.1 2003/11/01 00:11:20 dxie ship $ */


/*===========================================================================

  PROCEDURE NAME:	test_get_release_num

===========================================================================*/
   PROCEDURE test_get_release_num (X_po_header_id IN NUMBER) IS

   X_release_numa     NUMBER;

   BEGIN

   dbms_output.put_line('before call');

   po_releases_sv4.get_release_num(X_po_header_id, X_release_numa);

   dbms_output.put_line('after call');
   dbms_output.put_line(X_release_numa);

   END test_get_release_num;


/*===========================================================================

  PROCEDURE NAME:	test_val_doc_num_unique

===========================================================================*/
   PROCEDURE test_val_doc_num_unique (X_po_header_id   IN NUMBER,
				      X_release_num    IN NUMBER,
			              X_rowid IN VARCHAR2) IS

      BEGIN

         dbms_output.put_line('before call');

         IF po_releases_sv4.val_doc_num_unique(X_po_header_id,
					      X_release_num,
					      X_rowid) THEN
	    dbms_output.put_line('returned TRUE');
	 ELSE
	    dbms_output.put_line('returned FALSE');

	 END IF;

      END test_val_doc_num_unique;


/*===========================================================================

  PROCEDURE NAME:	test_val_approval_status

===========================================================================*/
   PROCEDURE test_val_approval_status(
		       X_po_release_id            IN NUMBER,
		       X_release_num              IN NUMBER,
		       X_agent_id                 IN NUMBER,
		       X_release_date             IN DATE,
	 	       X_acceptance_required_flag IN VARCHAR2,
		       X_acceptance_due_date      IN VARCHAR2) IS


      BEGIN

         dbms_output.put_line('before call');

	 IF po_releases_sv4.val_approval_status(
		       X_po_release_id,
		       X_release_num,
		       X_agent_id,
		       X_release_date,
	 	       X_acceptance_required_flag,
		       X_acceptance_due_date,
                       NULL) -- <INBOUND LOGISTICS FPJ>
         THEN
	    dbms_output.put_line('TRUE');
         ELSE
            dbms_output.put_line('FALSE');
         END IF;

      END test_val_approval_status;


END PO_RELEASES_SV3;

/
