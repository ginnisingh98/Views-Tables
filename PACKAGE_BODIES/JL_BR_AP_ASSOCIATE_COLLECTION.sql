--------------------------------------------------------
--  DDL for Package Body JL_BR_AP_ASSOCIATE_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AP_ASSOCIATE_COLLECTION" as
/* $Header: jlbrpacb.pls 120.2.12010000.3 2010/02/22 15:18:25 mbarrett ship $ */

   -- Logging Infra
   G_CURRENT_RUNTIME_LEVEL      NUMBER;
   G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
   G_MODULE_NAME                CONSTANT VARCHAR2(50) :=
                               'JL.PLSQL.JL_BR_AP_ASSOCIATE_COLLECTION.';




/*-----------------------------------------------------------*/
/*<<<<<		JL_BR_AP_ASSOCIATE_COLL_DOC		>>>>>*/
/*-----------------------------------------------------------*/
PROCEDURE jl_br_ap_associate_coll_doc (
	bank_collection_id_e IN NUMBER,
	association_method_e IN VARCHAR2,
	invoice_id_s IN OUT NOCOPY NUMBER,
	payment_num_s IN OUT NOCOPY NUMBER,
	associate_flag_s IN OUT NOCOPY VARCHAR2 )
IS
x_enable_bank_coll			VARCHAR2(1);
x_enable_association			VARCHAR2(1);
   --  Logging Infra:
   l_procedure_name  CONSTANT  VARCHAR2(30) := 'jl_br_ap_associate_coll_doc';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
   -- Logging Infra:

/*-----------------------------------------------------------*/
/*			ASSOCIATE_COLL_DOC		     */
/*-----------------------------------------------------------*/
PROCEDURE associate_coll_doc (
		bank_collection_id_e	IN NUMBER,
	        association_method_e  IN VARCHAR2,
		invoice_id_s	IN OUT NOCOPY NUMBER,
		payment_num_s	IN OUT NOCOPY NUMBER,
		associate_flag_s	OUT NOCOPY VARCHAR2 )
IS
 x_selected			VARCHAR2(1);
   --  Logging
   l_procedure_name  CONSTANT  VARCHAR2(30) := 'associate_coll_doc';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
   -- Logging

BEGIN
   x_selected := 'Y';
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
      l_log_msg := 'Parameters : bank_collection_id_e ' || bank_collection_id_e ||
                   ' Association_method ' || association_method_e;
   END IF;
   BEGIN
      IF (association_method_e = 'METHOD1') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD1';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Due date */
	SELECT  apps.invoice_id, apps.payment_num
	INTO    invoice_id_s, payment_num_s
	FROM    ap_payment_schedules_ALL apps,
		jl_br_ap_collection_docs jlbl,
		ap_invoices_ALL apinv
	WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       (( substr( apinv.invoice_num,1,15 ) = jlbl.document_number AND
		  apps.invoice_id = apinv.invoice_id ) AND
		( apps.due_date = jlbl.due_date )) AND
	       ( apinv.invoice_type_lookup_code = 'STANDARD') AND
		( apps.global_attribute11 IS NULL ) AND
	        ( apinv.cancelled_date IS NULL ) AND
	        (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD2') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Method2 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Supplier Site AND Supplier Name */
	SELECT  apps.invoice_id, apps.payment_num
	INTO    invoice_id_s, payment_num_s
	FROM    ap_payment_schedules_ALL apps,
		jl_br_ap_collection_docs jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847 / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       (( apinv.vendor_site_id = jlbl.vendor_site_id AND
		  apps.invoice_id = apinv.invoice_id ) AND
/*		( povs.vendor_site_id = jlbl.vendor_site_id AND */
		 ( apinv.vendor_id = jlbl.vendor_id AND /*povs.vendor_id AND*/
		  apps.invoice_id = apinv.invoice_id ) ) AND
	       ( apinv.invoice_type_lookup_code = 'STANDARD') AND
		( apps.global_attribute11 IS NULL ) AND
	        ( apinv.cancelled_date IS NULL ) AND
	        (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD3') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD3';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Supplier Site OR Supplier Name */
	BEGIN
		SELECT  apps.invoice_id, apps.payment_num
		INTO    invoice_id_s, payment_num_s
		FROM    ap_payment_schedules_ALL apps,
			jl_br_ap_collection_docs jlbl,
			ap_invoices_ALL apinv
		WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       		(( apinv.vendor_site_id = jlbl.vendor_site_id AND
		  	apps.invoice_id = apinv.invoice_id ) ) AND
	       		( apinv.invoice_type_lookup_code = 'STANDARD') AND
		        ( apps.global_attribute11 IS NULL ) AND
	        	( apinv.cancelled_date IS NULL ) AND
	        	(nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                        AND apinv.invoice_currency_code = jlbl.currency_code;
      	EXCEPTION
      		WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      			x_selected := 'N';
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'Exception, x_selected set to N';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

	END;
	IF x_selected = 'N' THEN
		SELECT  apps.invoice_id, apps.payment_num
		INTO    invoice_id_s, payment_num_s
		FROM    ap_payment_schedules_ALL apps,
			jl_br_ap_collection_docs jlbl,
			ap_invoices_ALL apinv
                        /* Bug # 635847 / 659227
                        ,
			po_vendor_sites povs
                        */
		WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
/*			(( povs.vendor_site_id = jlbl.vendor_site_id AND */
		  	((apinv.vendor_id = jlbl.vendor_id AND /*povs.vendor_id AND*/
		  	apps.invoice_id = apinv.invoice_id ) ) AND
	       		( apinv.invoice_type_lookup_code = 'STANDARD') AND
		        ( apps.global_attribute11 IS NULL ) AND
	        	( apinv.cancelled_date IS NULL ) AND
	        	(nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                        AND apinv.invoice_currency_code = jlbl.currency_code;
		x_selected:='Y';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Next select executed and x_selected is set to Y';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
	END IF;
      ELSIF (association_method_e = 'METHOD4') THEN
	 /* Invoice Number AND Due date AND Supplier Site */
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD4';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	SELECT  apps.invoice_id, apps.payment_num
	INTO    invoice_id_s, payment_num_s
	FROM    ap_payment_schedules_ALL apps,
		jl_br_ap_collection_docs jlbl,
		ap_invoices_ALL apinv
	WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       (( substr( apinv.invoice_num,1,15 ) = jlbl.document_number AND
		  apps.invoice_id = apinv.invoice_id ) AND
		( apps.due_date = jlbl.due_date ) AND
		( apinv.vendor_site_id = jlbl.vendor_site_id AND
		  apps.invoice_id = apinv.invoice_id ) ) AND
	       ( apinv.invoice_type_lookup_code = 'STANDARD') AND
		( apps.global_attribute11 IS NULL ) AND
	        ( apinv.cancelled_date IS NULL ) AND
	        (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD5') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD5 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	 /* Invoice Number AND Due date AND Supplier Name */
	SELECT  apps.invoice_id, apps.payment_num
	INTO    invoice_id_s, payment_num_s
	FROM    ap_payment_schedules_ALL apps,
		jl_br_ap_collection_docs jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847 / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       (( substr( apinv.invoice_num,1,15 ) = jlbl.document_number AND
		  apps.invoice_id = apinv.invoice_id ) AND
		( apps.due_date = jlbl.due_date ) AND
	/*	( povs.vendor_site_id = jlbl.vendor_site_id AND */
		 ( apinv.vendor_id = jlbl.vendor_id AND /*povs.vendor_id AND*/
		  apps.invoice_id = apinv.invoice_id ) ) AND
	       ( apinv.invoice_type_lookup_code = 'STANDARD') AND
		( apps.global_attribute11 IS NULL ) AND
	        ( apinv.cancelled_date IS NULL ) AND
	        (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD6') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD6';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date */
	SELECT  apps.invoice_id, apps.payment_num
	INTO    invoice_id_s, payment_num_s
	FROM    ap_payment_schedules_ALL apps,
		jl_br_ap_collection_docs jlbl,
		ap_invoices_ALL apinv
	WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       (( substr( apinv.invoice_num,1,15 ) = jlbl.document_number AND
		  apps.invoice_id = apinv.invoice_id ) AND
	       	( nvl(apps.gross_amount,0) = nvl(jlbl.amount,0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  apinv.payment_currency_code = jlbl.currency_code ) AND
		( apps.due_date = jlbl.due_date ) ) AND
	       ( apinv.invoice_type_lookup_code = 'STANDARD') AND
		( apps.global_attribute11 IS NULL ) AND
	        ( apinv.cancelled_date IS NULL ) AND
	        (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD7') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD7';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date AND Supplier Site */
	SELECT  apps.invoice_id, apps.payment_num
	INTO    invoice_id_s, payment_num_s
	FROM    ap_payment_schedules_ALL apps,
		jl_br_ap_collection_docs jlbl,
		ap_invoices_ALL apinv
	WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       (( substr( apinv.invoice_num,1,15 ) = jlbl.document_number AND
		  apps.invoice_id = apinv.invoice_id ) AND
	       	( nvl(apps.gross_amount,0) = nvl(jlbl.amount,0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  apinv.payment_currency_code = jlbl.currency_code ) AND
		( apps.due_date = jlbl.due_date ) AND
		( apinv.vendor_site_id = jlbl.vendor_site_id AND
		  apps.invoice_id = apinv.invoice_id ) ) AND
	       ( apinv.invoice_type_lookup_code = 'STANDARD') AND
		( apps.global_attribute11 IS NULL ) AND
	        ( apinv.cancelled_date IS NULL ) AND
	        (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD8') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD8';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date AND Supplier Name */
	SELECT  apps.invoice_id, apps.payment_num
	INTO    invoice_id_s, payment_num_s
	FROM    ap_payment_schedules_ALL apps,
		jl_br_ap_collection_docs jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847 / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       (( substr( apinv.invoice_num,1,15 ) = jlbl.document_number AND
		  apps.invoice_id = apinv.invoice_id ) AND
	       	( nvl(apps.gross_amount,0) = nvl(jlbl.amount,0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  apinv.payment_currency_code = jlbl.currency_code ) AND
		( apps.due_date = jlbl.due_date ) AND
/*		( povs.vendor_site_id = jlbl.vendor_site_id AND*/
		( apinv.vendor_id = jlbl.vendor_id AND /*povs.vendor_id AND*/
		  apps.invoice_id = apinv.invoice_id ) ) AND
	       ( apinv.invoice_type_lookup_code ='STANDARD') AND
		( apps.global_attribute11 IS NULL ) AND
	        ( apinv.cancelled_date IS NULL ) AND
	        (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD9') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD9';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date AND Supplier Site */
	/* AND Supplier Name */
	SELECT  apps.invoice_id, apps.payment_num
	INTO    invoice_id_s, payment_num_s
	FROM    ap_payment_schedules_ALL apps,
		jl_br_ap_collection_docs jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847 / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       (( substr( apinv.invoice_num,1,15 ) = jlbl.document_number AND
		  apps.invoice_id = apinv.invoice_id ) AND
	       	( nvl(apps.gross_amount,0) = nvl(jlbl.amount,0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  apinv.payment_currency_code = jlbl.currency_code ) AND
		( apps.due_date = jlbl.due_date ) AND
		( apinv.vendor_site_id = jlbl.vendor_site_id AND
		  apps.invoice_id = apinv.invoice_id ) AND
/*		( povs.vendor_site_id = jlbl.vendor_site_id AND */
		 ( apinv.vendor_id = jlbl.vendor_id AND /*povs.vendor_id AND */
		  apps.invoice_id = apinv.invoice_id ) ) AND
	       ( apinv.invoice_type_lookup_code ='STANDARD') AND
		( apps.global_attribute11 IS NULL ) AND
	        ( apinv.cancelled_date IS NULL ) AND
	        (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD10') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD10';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date OR Supplier Site */
	/* AND Supplier Name */
	BEGIN
	    SELECT  apps.invoice_id, apps.payment_num
	    INTO    invoice_id_s, payment_num_s
	    FROM    ap_payment_schedules_ALL apps,
	    	    jl_br_ap_collection_docs jlbl,
		    ap_invoices_ALL apinv
	    WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	           (( substr( apinv.invoice_num,1,15 ) = jlbl.document_number AND
		      apps.invoice_id = apinv.invoice_id ) AND
	       	( nvl(apps.gross_amount,0) = nvl(jlbl.amount,0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  apinv.payment_currency_code = jlbl.currency_code ) AND
		    ( apps.due_date = jlbl.due_date ) ) AND
	           ( apinv.invoice_type_lookup_code ='STANDARD') AND
		    ( apps.global_attribute11 IS NULL ) AND
	            ( apinv.cancelled_date IS NULL ) AND
	            (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;
      	EXCEPTION
      		WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      			x_selected := 'N';
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'Exception, x_selected set to N';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

	END;
	IF x_selected = 'N' THEN
	    SELECT  apps.invoice_id, apps.payment_num
	    INTO    invoice_id_s, payment_num_s
	    FROM    ap_payment_schedules_ALL apps,
	    	    jl_br_ap_collection_docs jlbl,
		    ap_invoices_ALL apinv
                    /* Bug # 635847 / 659227
                    ,
		    po_vendor_sites povs
                    */
	    WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
		    (( apinv.vendor_site_id = jlbl.vendor_site_id AND
		      apps.invoice_id = apinv.invoice_id ) AND
/*		( povs.vendor_site_id = jlbl.vendor_site_id AND */
		 ( apinv.vendor_id = jlbl.vendor_id AND /*povs.vendor_id AND */
		      apps.invoice_id = apinv.invoice_id ) ) AND
	           ( apinv.invoice_type_lookup_code ='STANDARD') AND
		    ( apps.global_attribute11 IS NULL ) AND
	            ( apinv.cancelled_date IS NULL ) AND
	            (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;
	    x_selected:= 'Y';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Next select executed and x_selected is set to Y';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
	END IF;

      ELSIF (association_method_e = 'METHOD11') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD11';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number OR Gross Amount AND Due Date AND Supplier Site */
	BEGIN
	    SELECT  apps.invoice_id, apps.payment_num
	    INTO    invoice_id_s, payment_num_s
	    FROM    ap_payment_schedules_ALL apps,
		    jl_br_ap_collection_docs jlbl,
		    ap_invoices_ALL apinv
	    WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	           (( substr( apinv.invoice_num,1,15 ) = jlbl.document_number AND
		      apps.invoice_id = apinv.invoice_id ) ) AND
	           ( apinv.invoice_type_lookup_code ='STANDARD') AND
		    ( apps.global_attribute11 IS NULL ) AND
	            ( apinv.cancelled_date IS NULL ) AND
	            (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;
      	EXCEPTION
      		WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      			x_selected := 'N';
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'Exception, x_selected set to N';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

	END;
	IF x_selected = 'N' THEN
	    SELECT  apps.invoice_id, apps.payment_num
	    INTO    invoice_id_s, payment_num_s
	    FROM    ap_payment_schedules_ALL apps,
		    jl_br_ap_collection_docs jlbl,
		    ap_invoices_ALL apinv
	    WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       	   (( nvl(apps.gross_amount,0) = nvl(jlbl.amount,0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  apinv.payment_currency_code = jlbl.currency_code ) AND
		    ( apps.due_date = jlbl.due_date ) AND
		    ( apinv.vendor_site_id = jlbl.vendor_site_id AND
		      apps.invoice_id = apinv.invoice_id ) ) AND
	           ( apinv.invoice_type_lookup_code ='STANDARD') AND
		    ( apps.global_attribute11 IS NULL ) AND
	            ( apinv.cancelled_date IS NULL ) AND
	            (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;
	    x_selected:= 'Y';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Next select executed and x_selected is set to Y';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
	END IF;
      ELSIF (association_method_e = 'METHOD12') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD12';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Gross Amount AND Due Date AND Supplier Site */
	    SELECT  apps.invoice_id, apps.payment_num
	    INTO    invoice_id_s, payment_num_s
	    FROM    ap_payment_schedules_ALL apps,
		    jl_br_ap_collection_docs jlbl,
		    ap_invoices_ALL apinv
	    WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       	   (( nvl(apps.gross_amount,0) = nvl(jlbl.amount,0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  apinv.payment_currency_code = jlbl.currency_code ) AND
		    ( apps.due_date = jlbl.due_date ) AND
		    ( apinv.vendor_site_id = jlbl.vendor_site_id AND
		      apps.invoice_id = apinv.invoice_id ) ) AND
	           ( apinv.invoice_type_lookup_code ='STANDARD') AND
		    ( apps.global_attribute11 IS NULL ) AND
	            ( apinv.cancelled_date IS NULL ) AND
	            (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD13') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD13';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Gross Amount AND Due Date AND Supplier Name */
	SELECT  apps.invoice_id, apps.payment_num
	INTO    invoice_id_s, payment_num_s
	FROM    ap_payment_schedules_ALL apps,
		jl_br_ap_collection_docs jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847  / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  jlbl.bank_collection_id = bank_collection_id_e AND
	       (( nvl(apps.gross_amount,0) = nvl(jlbl.amount,0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  apinv.payment_currency_code = jlbl.currency_code ) AND
		( apps.due_date = jlbl.due_date ) AND
/*		( povs.vendor_site_id = jlbl.vendor_site_id AND*/
		( apinv.vendor_id = jlbl.vendor_id AND /*povs.vendor_id AND*/
		  apps.invoice_id = apinv.invoice_id ) ) AND
	       ( apinv.invoice_type_lookup_code ='STANDARD') AND
		( apps.global_attribute11 IS NULL ) AND
	        ( apinv.cancelled_date IS NULL ) AND
	        (nvl(substr(apinv.global_attribute1,1,1),'N') = 'Y')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      END IF;
      EXCEPTION
      	-- Original condition Commented WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      	WHEN NO_DATA_FOUND THEN
      		x_selected := 'N';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Exception NO_DATA_FOUND, x_selected set to N';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
        -- Added for debugging
      	WHEN TOO_MANY_ROWS THEN
      		x_selected := 'N';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Exception TOO_MANY_ROWS, x_selected set to N';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
   END;
   IF x_selected = 'Y' THEN  /* Create the link with two tables */
	UPDATE jl_br_ap_collection_docs
	SET invoice_id = invoice_id_s,
    	    payment_num = payment_num_s
	WHERE bank_collection_id = bank_collection_id_e;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Updated jl_br_ap_collection_docs invoice_id ' ||
                       invoice_id_s || ' payment_num' || payment_num_s;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

        -- Bug Number 659227 / R11 Patch / May 98 (Copying Y to GA8)
	UPDATE ap_payment_schedules
	SET global_attribute11 = bank_collection_id_e,
	    global_attribute8  = 'Y'
	WHERE invoice_id = invoice_id_s
      	AND   payment_num = payment_num_s;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Updated ap_payment_schedules global_attribute11 ' || bank_collection_id_e;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
	associate_flag_s := 'Y';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'associate_flag_s is set to Y';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
   ELSE
	associate_flag_s := 'N';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'associate_flag_s is set to N';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
   END IF;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
   END IF;
END associate_coll_doc;

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
   END IF;
  SELECT global_attribute1,
	 global_attribute2
  INTO x_enable_bank_coll,
       x_enable_association
  FROM ap_system_parameters;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Value of x_enable_bank_coll ' || x_enable_bank_coll
                   || ' x_enable_association ' || x_enable_association;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

  IF x_enable_bank_coll = 'Y' THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'x_enable_bank_coll is Y';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;
	IF x_enable_association = 'Y' THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'x_enable_association is Y callined associate_coll_doc';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
		associate_coll_doc( bank_collection_id_e, association_method_e,
			      invoice_id_s, payment_num_s, associate_flag_s );
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 l_log_msg := 'After calling associate_coll_doc returned values ';
                 l_log_msg :=l_log_msg || 'invoice_id_s ' || invoice_id_s;
                 l_log_msg :=l_log_msg || 'payment_num_s ' || payment_num_s;
                 l_log_msg :=l_log_msg || 'associate_flag_s ' || associate_flag_s;
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
              END IF;
		IF associate_flag_s = 'Y' THEN /* If associated, release both*/
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'associate_flag_s is Y';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;
		   UPDATE ap_payment_schedules
		   SET hold_flag = 'N'
		   WHERE invoice_id = invoice_id_s
		   AND payment_num = payment_num_s;
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'updated hold flag to N in ap_payment_schedules';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

		   UPDATE jl_br_ap_collection_docs
		   SET hold_flag = 'N'
		   WHERE bank_collection_id = bank_collection_id_e;
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'updated hold flag to N in jl_br_ap_collection_docs';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

		ELSE /* If not associated, hold the collection document */
		   UPDATE jl_br_ap_collection_docs
		   SET hold_flag = 'Y'
		   WHERE bank_collection_id = bank_collection_id_e;
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'associate_flag_s is N updated hold_flag to Y in jl_br_ap_collection_docs';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

		END IF;
	ELSE /* If association is not enabled, hold the collection document */
		UPDATE jl_br_ap_collection_docs
		SET hold_flag = 'Y'
		WHERE bank_collection_id = bank_collection_id_e;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'x_enable_association is N update hold flag to Y in jl_br_ap_collection_docs';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

	END IF;
  ELSE /* If bank collection is not enabled, release the collection document*/
	UPDATE jl_br_ap_collection_docs
	SET hold_flag = 'N'
	WHERE bank_collection_id = bank_collection_id_e;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'x_enable_bank_coll is N update hold flag to N in jl_br_ap_collection_docs';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

  END IF;
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := l_procedure_name||'(-)';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;
END jl_br_ap_associate_coll_doc;
/*-----------------------------------------------------------*/
/*<<<<<		JL_BR_AP_ASSOCIATE_TRADE_NOTE		>>>>>*/
/*-----------------------------------------------------------*/
PROCEDURE jl_br_ap_associate_trade_note (
	invoice_id_e IN NUMBER,
	payment_num_e IN NUMBER,
	association_method_e IN VARCHAR2,
	bank_collection_id_s IN OUT NOCOPY NUMBER,
	associate_flag_s IN OUT NOCOPY VARCHAR2 )
IS
x_enable_bank_coll	ap_system_parameters.global_attribute1%TYPE;
x_enable_association	ap_system_parameters.global_attribute2%TYPE;
x_payment_status_flag		ap_payment_schedules.payment_status_flag%TYPE;
   --  Logging Infra:
   l_procedure_name  CONSTANT  VARCHAR2(30) := 'jl_br_ap_associate_trade_note';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
   -- Logging Infra:
/*-----------------------------------------------------------*/
/*			ASSOCIATE_TRADE_NOTE			     */
/*-----------------------------------------------------------*/
PROCEDURE associate_trade_note (
		invoice_id_e	IN NUMBER,
		payment_num_e	IN NUMBER,
	        association_method_e  	IN VARCHAR2,
		bank_collection_id_s	IN OUT NOCOPY NUMBER,
		associate_flag_s	OUT NOCOPY VARCHAR2 )
IS
x_selected					VARCHAR2(1);
   --  Logging Infra:
   l_procedure_name  CONSTANT  VARCHAR2(30) := 'associate_trade_note';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
   -- Logging Infra:

BEGIN
   x_selected := 'Y';
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
   END IF;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Parameters : invoice_id_e ' || invoice_id_e || ' payment_num_e ' || payment_num_e ||
                   ' Association_method_e ' || association_method_e;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   BEGIN
      IF (association_method_e = 'METHOD1') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD1 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Due date */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM 	ap_payment_schedules apps,
		jl_br_ap_collection_docs_ALL jlbl,
		ap_invoices_ALL apinv
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( apinv.invoice_id = apps.invoice_id AND
	    	  jlbl.document_number = substr( apinv.invoice_num,1,15 )) AND
	  	( jlbl.due_date = apps.due_date ) ) AND
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD2') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD2 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Supplier Site and Supplier Name */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM 	ap_payment_schedules apps,
		jl_br_ap_collection_docs_ALL jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847  / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( apinv.invoice_id = apps.invoice_id AND
	    	jlbl.vendor_site_id = apinv.vendor_site_id ) AND
	  	( apinv.invoice_id = apps.invoice_id AND
/*	    	povs.vendor_id*/ jlbl.vendor_id = apinv.vendor_id )) AND
/*	    	jlbl.vendor_site_id = povs.vendor_site_id ) ) AND*/
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD3') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD3 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Supplier Site OR Supplier Name */
	BEGIN
		SELECT bank_collection_id
		INTO bank_collection_id_s
		FROM 	ap_payment_schedules apps,
			jl_br_ap_collection_docs_ALL jlbl,
			ap_invoices_ALL apinv
		WHERE  apps.invoice_id = invoice_id_e	AND
	       	       apps.payment_num = payment_num_e AND
	       	       (( apinv.invoice_id = apps.invoice_id AND
	    	       jlbl.vendor_site_id = apinv.vendor_site_id )) AND
			( jlbl.invoice_id IS NULL AND
	  	  	jlbl.payment_num IS NULL ) AND
			( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;
      	EXCEPTION
      		WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      			x_selected := 'N';
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'Exception, x_selected set to N';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

	END;
	IF x_selected = 'N' THEN
		SELECT bank_collection_id
		INTO bank_collection_id_s
		FROM 	ap_payment_schedules apps,
			jl_br_ap_collection_docs_ALL jlbl,
			ap_invoices_ALL apinv
                        /* Bug # 635847  / 659227
                        ,
		        po_vendor_sites povs
                        */
		WHERE  apps.invoice_id = invoice_id_e	AND
	       		apps.payment_num = payment_num_e AND
	  		(( apinv.invoice_id = apps.invoice_id AND
/*	    	povs.vendor_id*/ jlbl.vendor_id = apinv.vendor_id )) AND
/*	    	jlbl.vendor_site_id = povs.vendor_site_id ) ) AND*/
		        ( jlbl.invoice_id IS NULL AND
	  	        jlbl.payment_num IS NULL ) AND
			( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;
	    x_selected:= 'Y';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Next select executed and x_selected is set to Y';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
	END IF;
      ELSIF (association_method_e = 'METHOD4') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD4 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	 /* Invoice Number AND Due date AND Supplier Site */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM 	ap_payment_schedules apps,
		jl_br_ap_collection_docs_ALL jlbl,
		ap_invoices_ALL apinv
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( apinv.invoice_id = apps.invoice_id AND
	    	  jlbl.document_number = substr( apinv.invoice_num,1,15 ) ) AND
	  	( jlbl.due_date = apps.due_date ) AND
	  	( apinv.invoice_id = apps.invoice_id AND
	    	jlbl.vendor_site_id = apinv.vendor_site_id ) ) AND
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD5') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD5 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	 /* Invoice Number AND Due date AND Supplier Name */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM 	ap_payment_schedules apps,
		jl_br_ap_collection_docs_ALL jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847  / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( apinv.invoice_id = apps.invoice_id AND
	    	  jlbl.document_number = substr( apinv.invoice_num,1,15 ) ) AND
	  	( jlbl.due_date = apps.due_date ) AND
	  	( apinv.invoice_id = apps.invoice_id AND
/*	    	povs.vendor_id*/ jlbl.vendor_id = apinv.vendor_id )) AND
/*	    	jlbl.vendor_site_id = povs.vendor_site_id ) ) AND*/
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD6') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD6 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM 	ap_payment_schedules apps,
		jl_br_ap_collection_docs_ALL jlbl,
		ap_invoices_ALL apinv
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( apinv.invoice_id = apps.invoice_id AND
	    	  jlbl.document_number = substr( apinv.invoice_num,1,15 ) ) AND
		( nvl(jlbl.amount, 0) = nvl(apps.gross_amount, 0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  jlbl.currency_code = apinv.payment_currency_code ) AND
	  	( jlbl.due_date = apps.due_date ) ) AND
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD7') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD7 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date AND Supplier Site */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM 	ap_payment_schedules apps,
		jl_br_ap_collection_docs_ALL jlbl,
		ap_invoices_ALL apinv
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( apinv.invoice_id = apps.invoice_id AND
	    	  jlbl.document_number = substr( apinv.invoice_num,1,15 ) ) AND
		( nvl(jlbl.amount, 0) = nvl(apps.gross_amount, 0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  jlbl.currency_code = apinv.payment_currency_code ) AND
	  	( jlbl.due_date = apps.due_date ) AND
	  	( apinv.invoice_id = apps.invoice_id AND
	    	jlbl.vendor_site_id = apinv.vendor_site_id ) ) AND
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
	       (jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD8') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD8 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date AND Supplier Name */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM 	ap_payment_schedules apps,
		jl_br_ap_collection_docs_ALL jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847  / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( apinv.invoice_id = apps.invoice_id AND
	    	  jlbl.document_number = substr( apinv.invoice_num,1,15 ) ) AND
		( nvl(jlbl.amount, 0) = nvl(apps.gross_amount, 0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  jlbl.currency_code = apinv.payment_currency_code ) AND
	  	( jlbl.due_date = apps.due_date ) AND
	  	( apinv.invoice_id = apps.invoice_id AND
/*	    	povs.vendor_id*/ jlbl.vendor_id = apinv.vendor_id )) AND
/*	    	jlbl.vendor_site_id = povs.vendor_site_id ) ) AND*/
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD9') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD9 ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date AND Supplier Site */
	/* AND Supplier Name */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM 	ap_payment_schedules apps,
		jl_br_ap_collection_docs_ALL jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847  / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( apinv.invoice_id = apps.invoice_id AND
	    	  jlbl.document_number = substr( apinv.invoice_num,1,15 ) ) AND
		( nvl(jlbl.amount, 0) = nvl(apps.gross_amount, 0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  jlbl.currency_code = apinv.payment_currency_code ) AND
	  	( jlbl.due_date = apps.due_date ) AND
	  	( apinv.invoice_id = apps.invoice_id AND
	    	jlbl.vendor_site_id = apinv.vendor_site_id ) AND
	  	( apinv.invoice_id = apps.invoice_id AND
/*	    	povs.vendor_id*/ jlbl.vendor_id = apinv.vendor_id )) AND
/*	    	jlbl.vendor_site_id = povs.vendor_site_id ) ) AND*/
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD10') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD10';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number AND Gross Amount AND Due Date OR Supplier Site */
	/* AND Supplier Name */
	BEGIN
	    SELECT bank_collection_id
	    INTO bank_collection_id_s
	    FROM 	ap_payment_schedules apps,
		    jl_br_ap_collection_docs_ALL jlbl,
		    ap_invoices_ALL apinv
	    WHERE  apps.invoice_id = invoice_id_e	AND
	           apps.payment_num = payment_num_e AND
	           (( apinv.invoice_id = apps.invoice_id AND
	    	      jlbl.document_number = substr( apinv.invoice_num,1,15 ) ) AND
		( nvl(jlbl.amount, 0) = nvl(apps.gross_amount, 0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  jlbl.currency_code = apinv.payment_currency_code ) AND
	  	    ( jlbl.due_date = apps.due_date ) ) AND
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		    ( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;
      	EXCEPTION
      		WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      			x_selected := 'N';
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'Exception, x_selected set to N';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

	END;
	IF x_selected = 'N' THEN
	    SELECT bank_collection_id
	    INTO bank_collection_id_s
	    FROM    ap_payment_schedules apps,
		    jl_br_ap_collection_docs_ALL jlbl,
		    ap_invoices_ALL apinv
                    /* Bug # 635847  / 659227
                    ,
		    po_vendor_sites povs
                    */
	    WHERE  apps.invoice_id = invoice_id_e	AND
	           apps.payment_num = payment_num_e AND
	  	    (( apinv.invoice_id = apps.invoice_id AND
	    	    jlbl.vendor_site_id = apinv.vendor_site_id ) AND
	  	    ( apinv.invoice_id = apps.invoice_id AND
/*	    	povs.vendor_id*/ jlbl.vendor_id = apinv.vendor_id )) AND
/*	    	jlbl.vendor_site_id = povs.vendor_site_id ) ) AND*/
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		    ( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;
	    x_selected:= 'Y';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Next select executed and x_selected is set to Y';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
      	END IF;

      ELSIF (association_method_e = 'METHOD11') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD11';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Invoice number OR Gross Amount AND Due Date AND Supplier Site */
	BEGIN
	    SELECT bank_collection_id
	    INTO bank_collection_id_s
	    FROM    ap_payment_schedules apps,
		    jl_br_ap_collection_docs_ALL jlbl,
		    ap_invoices_ALL apinv
	    WHERE  apps.invoice_id = invoice_id_e	AND
	           apps.payment_num = payment_num_e AND
	           (( apinv.invoice_id = apps.invoice_id AND
	    	      jlbl.document_number = substr( apinv.invoice_num,1,15 ) ) ) AND
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		    ( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;
      	EXCEPTION
      		WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      			x_selected := 'N';
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'Exception, x_selected set to N';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

	END;
	IF x_selected = 'N' THEN
	    SELECT bank_collection_id
	    INTO bank_collection_id_s
	    FROM    ap_payment_schedules apps,
		    jl_br_ap_collection_docs_ALL jlbl,
		    ap_invoices_ALL apinv
	    WHERE  apps.invoice_id = invoice_id_e	AND
	           apps.payment_num = payment_num_e AND
		   (( nvl(jlbl.amount, 0) = nvl(apps.gross_amount, 0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  jlbl.currency_code = apinv.payment_currency_code ) AND
	  	    ( jlbl.due_date = apps.due_date ) AND
	  	    ( apinv.invoice_id = apps.invoice_id AND
	    	    jlbl.vendor_site_id = apinv.vendor_site_id ) ) AND
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		    ( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;
	    x_selected:= 'Y';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Next select executed and x_selected is set to Y';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
	END IF;
      ELSIF (association_method_e = 'METHOD12') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD12';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Gross Amount AND Due Date AND Supplier Site */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM    ap_payment_schedules apps,
	    	jl_br_ap_collection_docs_ALL jlbl,
	    	ap_invoices_ALL apinv
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( nvl(jlbl.amount, 0) = nvl(apps.gross_amount, 0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  jlbl.currency_code = apinv.payment_currency_code ) AND
	  	    ( jlbl.due_date = apps.due_date ) AND
	  	    ( apinv.invoice_id = apps.invoice_id AND
	    	    jlbl.vendor_site_id = apinv.vendor_site_id ) ) AND
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		    ( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      ELSIF (association_method_e = 'METHOD13') THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'METHOD13';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
	/* Gross Amount AND Due Date AND Supplier Name */
	SELECT bank_collection_id
	INTO bank_collection_id_s
	FROM 	ap_payment_schedules apps,
		jl_br_ap_collection_docs_ALL jlbl,
		ap_invoices_ALL apinv
                /* Bug # 635847  / 659227
                ,
		po_vendor_sites povs
                */
	WHERE  apps.invoice_id = invoice_id_e	AND
	       apps.payment_num = payment_num_e AND
	       (( nvl(jlbl.amount, 0) = nvl(apps.gross_amount, 0) AND
		  apinv.invoice_id = apps.invoice_id AND
		  jlbl.currency_code = apinv.payment_currency_code ) AND
	  	( jlbl.due_date = apps.due_date ) AND
	  	( apinv.invoice_id = apps.invoice_id AND
/*	    	povs.vendor_id*/ jlbl.vendor_id = apinv.vendor_id )) AND
/*	    	jlbl.vendor_site_id = povs.vendor_site_id ) ) AND*/
		( jlbl.invoice_id IS NULL AND
	  	  jlbl.payment_num IS NULL ) AND
		( jlbl.status_lookup_code = 'ACTIVE')
                AND apinv.invoice_currency_code = jlbl.currency_code;

      END IF;
      EXCEPTION
      	WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      		x_selected := 'N';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Exception, x_selected set to N';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
   END;
   IF x_selected = 'Y' THEN /* Create the link with two tables */
        -- Bug Number 659227 / R11 Patch / May 98 (Copying Y to GA8)
	UPDATE ap_payment_schedules
	SET global_attribute11 = bank_collection_id_s,
	    global_attribute8  = 'Y'
	WHERE invoice_id = invoice_id_e AND
	      payment_num = payment_num_e;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Updated ap_payment_schedules global_attribute11 ' || bank_collection_id_s;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
	UPDATE jl_br_ap_collection_docs
	SET invoice_id = invoice_id_e,
	    payment_num = payment_num_e
	WHERE bank_collection_id = bank_collection_id_s;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Updated jl_br_ap~_collection_docs invoice_id ' || invoice_id_e;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
	associate_flag_s := 'Y';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'associate_flag_s set to Y updated values';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

   ELSE
	associate_flag_s := 'N';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'associate_flag_s set to N';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
   END IF;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
   END IF;
END associate_trade_note;

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
   END IF;
  SELECT global_attribute1
  INTO x_enable_bank_coll
  FROM ap_system_parameters;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Value of x_enable_bank_coll ' || x_enable_bank_coll;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

  SELECT global_attribute1
  INTO   x_enable_association
  FROM 	ap_invoices
  WHERE invoice_id = invoice_id_e;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Value of x_enable_association ' || x_enable_association;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

  IF x_enable_bank_coll = 'Y' THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'x_enable_bank_coll is Y';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;
	IF x_enable_association = 'Y' THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'x_enable_association is Y calling associate_trade_note';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
		associate_trade_note( invoice_id_e, payment_num_e,
			      association_method_e, bank_collection_id_s,
			      associate_flag_s );
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'After calling associate_trade_note returned values ';
              l_log_msg :=l_log_msg || 'bank_collection_id_s ' || bank_collection_id_s;
              l_log_msg :=l_log_msg || 'associate_flag_s ' || associate_flag_s;
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

		IF associate_flag_s = 'Y' THEN /* Se associou, */
					     /* libera os dois */
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'associate_flag_s is Y';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

		   UPDATE ap_payment_schedules
		   SET hold_flag = 'N'
		   WHERE invoice_id = invoice_id_e
		   AND payment_num = payment_num_e;

		   UPDATE jl_br_ap_collection_docs
		   SET hold_flag = 'N'
		   WHERE bank_collection_id = bank_collection_id_s;
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'Updated hold to N in ar_payment_schedules, jl_br_ap_collection_docs';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

		ELSE /* If not associated and payment schedule not paid */
		     /* then hold the payment schedule 			*/
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'associate_flag_s is N';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;
		   SELECT payment_status_flag
		   INTO x_payment_status_flag
		   FROM ap_payment_schedules
		   WHERE invoice_id = invoice_id_e
		   AND   payment_num = payment_num_e;

                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'x_payment_status_flag is || x_payment_status_flag';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

		   IF (x_payment_status_flag = 'N') THEN
		   	UPDATE ap_payment_schedules
		   	SET hold_flag = 'Y'
		   	WHERE invoice_id = invoice_id_e
		   	AND payment_num = payment_num_e;
                      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                         l_log_msg := 'x_payment_status_flag N, Updated hold_flag_s Y in ap_payment_schedules';
                         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                      END IF;
		   END IF;
		END IF;
	ELSE /* If association not enabled, hold the payment schedule */
	   UPDATE ap_payment_schedules
	   SET hold_flag = 'Y'
	   WHERE invoice_id = invoice_id_e
	   AND payment_num = payment_num_e;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'x_enable_association is N updated ap_payment_schedules hold flag to Y';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

	END IF;
  ELSE /* If bank collection is not enabled, release the payment schedule */
	UPDATE ap_payment_schedules
   	SET hold_flag = 'N'
   	WHERE invoice_id = invoice_id_e
   	AND payment_num = payment_num_e;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'x_enable_bank_coll is N, updated ap_payment_schedules to N';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

  END IF;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
   END IF;
END jl_br_ap_associate_trade_note;

END JL_BR_AP_ASSOCIATE_COLLECTION;

/
