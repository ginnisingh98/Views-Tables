--------------------------------------------------------
--  DDL for Package Body IGC_CC_COMMON_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_COMMON_UTILS_PVT" AS
/*$Header: IGCUTILB.pls 120.2.12010000.3 2009/01/10 04:55:45 vensubra ship $*/

-- -----------------------------------------------------------------------
-- Declare global variables.
-- -----------------------------------------------------------------------
  G_PKG_NAME CONSTANT    VARCHAR2(30):= 'IGC_CC_COMMON_UTILS_PVT';
  l_debug_mode           VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');

PROCEDURE Put_Debug_Msg (
   p_debug_msg IN VARCHAR2
);

/*=======================================================================+
 |                       PROCEDURE Put_Debug_Msg                         |
 |                                                                       |
 | Note : This is a private function to output any debug information if  |
 |        debug is enabled for the system to determine any issue that    |
 |        may be happening at customer site.                             |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |                                                                       |
 |   p_debug_msg   This is the message that is to be output to log for   |
 |                 debugging purposes.                                   |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Put_Debug_Msg (
   p_debug_msg IN VARCHAR2
) IS

-- Constants :

   l_Return_Status    VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Put_Debug_Msg';
   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(3)           := 'CC';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';

BEGIN

   IGC_MSGS_PKG.Put_Debug_Msg (p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );
   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Put_Debug_Msg procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       RETURN;

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       RETURN;

END Put_Debug_Msg;

/*=======================================================================+
 |                      PROCEDURE Get_Header_Desc
 |                                                                       |
 | Note : This procedure is designed to get the descriptions of all the  |
 |        coded fields stored at the header level in igc_cc_headers      |
 |        It is used by forms like IGCCSUMM to get the descriptions      |
 |        of the field to be displayed to the user.                      |
 |                                                                       |
 |                                                                       |
 | Parameters :                                                          |
 |                                                                       |
 |  Standard header params for Public Procedures.                        |
 |                                                                       |
 |   p_api_version        Version number for API to run                  |
 |   p_init_msg_list      Message stack to be initialized flag           |
 |   p_commit             Is work to be commited here flag               |
 |   p_validation_level   Validation Level to be performed               |
 |   p_return_status      Status returned from Procedure                 |
 |   p_msg_count          Number of messages on stack returned           |
 |   p_msg_data           Message text information returned              |
 |                                                                       |
 |  Parameters for Procedure to process properly.                        |
 |   p_cc_header_id       igc_cc_headers.cc_header_id                    |
 |                                                                       |
 +=======================================================================*/
PROCEDURE Get_Header_Desc
(
   p_api_version         IN NUMBER,
   p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status      OUT NOCOPY VARCHAR2,
   p_msg_count          OUT NOCOPY NUMBER,
   p_msg_data           OUT NOCOPY VARCHAR2,

   p_cc_header_id        IN NUMBER,
   p_type_desc          OUT NOCOPY VARCHAR2,
   p_state_desc         OUT NOCOPY VARCHAR2,
   p_apprvl_status_desc OUT NOCOPY VARCHAR2,
   p_ctrl_status_desc   OUT NOCOPY VARCHAR2,
   p_cc_owner_name      OUT NOCOPY VARCHAR2,
   p_cc_preparer_name   OUT NOCOPY VARCHAR2,
   p_cc_access_level    OUT NOCOPY VARCHAR2,
   p_vendor_name        OUT NOCOPY VARCHAR2,
   p_bill_to_location   OUT NOCOPY VARCHAR2,
   p_vendor_site_code   OUT NOCOPY VARCHAR2,
   p_vendor_contact     OUT NOCOPY VARCHAR2,
   p_vendor_number      OUT NOCOPY VARCHAR2,
   p_term_name          OUT NOCOPY VARCHAR2,
   p_parent_cc_num      OUT NOCOPY VARCHAR2,
   p_vendor_hold_flag   OUT NOCOPY VARCHAR2)
IS

CURSOR c_get_header (p_cc_header_id     IN NUMBER)
IS
  SELECT cc_header_id,
         cc_type,
         cc_state,
         cc_ctrl_status,
         cc_encmbrnc_status,
         cc_apprvl_status,
         vendor_id,
         vendor_site_id,
         vendor_contact_id,
         term_id,
         location_id,
         cc_owner_user_id,
         cc_preparer_user_id,
         parent_header_id
  FROM   igc_cc_headers_all
  WHERE  cc_header_id = p_cc_header_id;


  l_header_rec       c_get_header%ROWTYPE;

  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_Return_Status    VARCHAR2(1);
  l_validation_error BOOLEAN                 := FALSE;
  l_api_name         CONSTANT VARCHAR2(30)   := 'Get_Header_Desc';
  l_api_version      CONSTANT NUMBER         :=  1.0;

BEGIN

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;

   -- --------------------------------------------------------------------
   -- Initialize Return status
   -- --------------------------------------------------------------------
   p_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN  c_get_header (p_cc_header_id);
   FETCH c_get_header INTO l_header_rec;
   CLOSE c_get_header;

   -- CC Type
   BEGIN
      SELECT lkpt.meaning
      INTO   p_type_desc
      FROM   fnd_lookups lkpt
      WHERE  lkpt.lookup_code  = l_header_rec.cc_type
      AND    lkpt.lookup_type  = 'IGC_CC_TYPE';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_type_desc := NULL ;
   END;

   -- CC State
   BEGIN
      SELECT lkpt.meaning
      INTO   p_state_desc
      FROM   fnd_lookups lkpt
      WHERE  lkpt.lookup_code  = l_header_rec.cc_state
      AND lkpt.lookup_type     = 'IGC_CC_STATE';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_state_desc := NULL;
   END;

   -- CC Apprvl Status
   BEGIN
      SELECT lkpt.meaning
      INTO   p_apprvl_status_desc
      FROM   fnd_lookups lkpt
      WHERE  lkpt.lookup_code  = l_header_rec.cc_apprvl_status
      AND lkpt.lookup_type  = 'IGC_CC_APPROVAL_STATUS';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       p_apprvl_status_desc := NULL;
   END;

   -- CC Ctrl Status
   BEGIN
      SELECT lkpt.meaning
      INTO   p_ctrl_status_desc
      FROM   fnd_lookups lkpt
      WHERE  lkpt.lookup_code  = l_header_rec.cc_ctrl_status
      AND lkpt.lookup_type  = 'IGC_CC_CONTROL_STATUS';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_ctrl_status_desc := NULL;
   END;

   -- Vendor Name
   -- Vendor Number
   -- Vendor Site Code
   BEGIN
      SELECT pv.vendor_name,
             pv.segment1,
             pv.hold_flag,
             pvs.vendor_site_code
      INTO  p_vendor_name,
            p_vendor_number,
            p_vendor_hold_flag,
            p_vendor_site_code
      FROM  po_vendors pv,
            po_vendor_sites_all pvs
      WHERE pv.vendor_id     = l_header_rec.vendor_id
      AND   pvs.vendor_site_id  = l_header_rec.vendor_site_id
      AND   pvs.vendor_id       =  pv.vendor_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_vendor_name      := NULL;
      p_vendor_number    := NULL;
      p_vendor_site_code := NULL;
      p_vendor_hold_flag        := NULL;
   END;

   -- Vendor Contact
   BEGIN
      SELECT pvc.first_name ||' '|| pvc.last_name
      INTO  p_vendor_contact
      FROM  po_vendor_contacts pvc
      WHERE pvc.vendor_contact_id (+) = l_header_rec.vendor_contact_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_vendor_contact := NULL;
   END;

   -- Preparer User Name
   BEGIN
      SELECT fup.user_name
      INTO   p_cc_preparer_name
      FROM   fnd_user fup
      WHERE  fup.user_id   = l_header_rec.cc_preparer_user_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_cc_preparer_name   := NULL;
   END;

   -- Owner User Name
   BEGIN
      SELECT fuo.user_name
      INTO   p_cc_owner_name
      FROM   fnd_user fuo
      WHERE  fuo.user_id   = l_header_rec.cc_owner_user_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_cc_owner_name := NULL;
   END;

   -- Term Name
   BEGIN
      SELECT  apt.name
      INTO    p_term_name
      FROM    ap_terms apt
      WHERE   apt.term_id = l_header_rec.term_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_term_name  := NULL;
   END;

   -- Bill to Location
   BEGIN
      SELECT hrl.location_code
      INTO   p_bill_to_location
      FROM   hr_locations hrl
      WHERE  hrl.location_id  = l_header_rec.location_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_bill_to_location  := NULL;
   END;

   -- Parent CC Num
   BEGIN
      SELECT cch.cc_num
      INTO   p_parent_cc_num
      FROM   igc_cc_headers_all cch
      WHERE  cch.cc_header_id  = l_header_rec.parent_header_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_parent_cc_num  := NULL;
   END;

   -- Access Level
   p_cc_access_level := SUBSTR(IGC_CC_ACCESS_PKG.get_access_level
                        (l_header_rec.cc_header_id,
                         FND_GLOBAL.USER_ID,
                         l_header_rec.cc_preparer_user_id,
                         l_header_rec.cc_owner_user_id), 1, 1);

   FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                               p_data  => p_msg_data );

   RETURN;

-- -------------------------------------------------------------------------
-- Exception handler section for the Validate_CCID procedure.
-- -------------------------------------------------------------------------
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    RETURN;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    RETURN;

  WHEN OTHERS THEN

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    RETURN;

END Get_Header_Desc;


FUNCTION DATE_IS_VALID(x_form_name VARCHAR2,
						x_gl_date gl_period_statuses.start_date%type,
						x_po_header_id po_headers_all.po_header_id%type,
						x_po_line_id   po_lines_all.po_line_id%type,
						x_line_location_id po_line_locations_all.line_location_id%type,
						x_po_distribution_id po_distributions_all.po_distribution_id%type,
						x_po_dist_num  po_distributions_all.distribution_num%type,
						x_shipment_num po_line_locations_all.shipment_num%type,
						x_line_num po_lines_all.line_num%type)
RETURN BOOLEAN
IS

l_cc_num       		po_headers.segment1%type;    /* cc number */
l_pf_date      		igc_cc_det_pf.cc_det_pf_date%type;            /* Payment forecast date */
l_CC_STATE 		igc_cc_headers.cc_state%type;
l_CC_CTRL_STATUS 	igc_cc_headers.CC_CTRL_STATUS%type;
l_CC_ENCMBRNC_STATUS igc_cc_headers.CC_ENCMBRNC_STATUS%type;
l_CC_APPRVL_STATUS 	igc_cc_headers.CC_APPRVL_STATUS%type;
l_status 		BOOLEAN;         /* holds value whether the CC can be matched or not */
l_fiscal_year_invoice 	gl_period_statuses.period_year%type;      /* fiscal year of invoice */
l_fiscal_year_pf   	gl_period_statuses.period_year%type;      /* fiscal year of specific Payment Forecast line */
l_period 		gl_period_statuses.period_name%TYPE;
l_open_gl_date 		gl_period_statuses.start_date%type;            /* Holds the next open gl date */
l_gl_date 		gl_period_statuses.start_date%type;
l_cc_det_pf_date        igc_cc_det_pf.cc_det_pf_date%type;
l_shipment_num          po_line_locations_all.shipment_num%type;
l_line_location_id      po_line_locations_all.line_location_id%type;

-- Cursor to get the account line id value
CURSOR c_acct_line(p_cc_num IN po_headers.segment1%type)
IS
	SELECT CC_acct_LINE_ID
        FROM IGC_CC_ACCT_LINES
        WHERE cc_header_id = (SELECT cc_header_id
                              FROM IGC_CC_HEADERS
                              WHERE CC_NUM = p_cc_num)
	AND CC_ACCT_LINE_NUM = x_shipment_num;

-- Cursor to get the distribution numbers of all the distributions for the CC
CURSOR for_each_dist_in_po(p_cc_num IN po_headers.segment1%type)
IS
SELECT distribution_num
FROM   po_distributions
WHERE  po_header_id = x_po_header_id
AND    po_line_id = x_po_line_id
AND    line_location_id = x_line_location_id;

-- Cursors for the call from Invoice Gateway
CURSOR c_get_po_line_id(p_po_header_id po_headers_all.po_header_id%type)
  IS SELECT po_line_id
     FROM po_lines
     WHERE po_header_id = p_po_header_id;

CURSOR c_get_shipment_num(p_po_line_id po_lines_all.po_line_id%type)
  IS SELECT line_location_id, shipment_num
     FROM po_line_locations
     WHERE po_line_id = p_po_line_id;

CURSOR c_get_cc_acct_line_id(p_shipment_num po_line_locations.shipment_num%type)
  IS SELECT cc_acct_line_id
     FROM igc_cc_acct_lines
     WHERE cc_header_id = (SELECT cc_header_id
                           FROM IGC_CC_HEADERS
                           WHERE CC_NUM = l_cc_num)
     AND cc_acct_line_num = p_shipment_num;

CURSOR c_get_distribution_num(p_po_line_id po_lines_all.po_line_id%type,
                                p_line_location_id po_line_locations.line_location_id%type)
  IS SELECT distribution_num
     FROM   po_distributions
     WHERE  po_header_id = x_po_header_id
     AND    po_line_id = p_po_line_id
     AND    line_location_id = p_line_location_id;


BEGIN
     l_status := TRUE;
     l_open_gl_date := NULL;
     l_gl_date := x_gl_date;

     /* Get the GL period is open or not */
     l_period := AP_UTILITIES_PKG.get_current_gl_date(l_gl_date);

     IF (l_period IS NULL) THEN
       ----------------------------------------------------------------------
       -- Get gl_period and Date from a future period
       ----------------------------------------------------------------------
     	    AP_UTILITIES_PKG.get_open_gl_date
	                		(l_gl_Date,
		       	                  l_period,
                		          l_open_gl_date
                        		 );
            l_gl_date := l_open_gl_date;

	    IF (l_gl_date IS NULL) THEN
	        FND_MESSAGE.SET_NAME('SQLAP','AP_DISTS_NO_OPEN_FUT_PERIOD');
    	        APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
     END IF;

     /*  cc number is stored in the segment1 so get it */
     BEGIN
	     SELECT segment1
	     INTO l_cc_num
	     FROM po_headers
	     WHERE po_header_id = x_po_header_id;
     EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
		FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
                FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
		APP_EXCEPTION.RAISE_EXCEPTION;
     END;


     /* Get the different status of the CC */
     BEGIN
	    SELECT CC_STATE,
	    	   CC_CTRL_STATUS,
	           CC_ENCMBRNC_STATUS,
	           CC_APPRVL_STATUS
	     INTO   l_CC_STATE,
        	    l_CC_CTRL_STATUS,
	            l_CC_ENCMBRNC_STATUS,
        	    l_CC_APPRVL_STATUS
	     FROM   IGC_CC_HEADERS
	     WHERE CC_NUM = l_cc_num;
     EXCEPTION
        /* No need to check for validation if its a PO, bug # 5687596*/
        WHEN NO_DATA_FOUND THEN
	     RETURN TRUE;
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
		FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
                FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
		APP_EXCEPTION.RAISE_EXCEPTION;
     END;


     /* Check whether the status of the CC is valid to be matched */
     IF l_CC_STATE = 'CM'
        AND  l_CC_CTRL_STATUS = 'O'
        AND l_CC_ENCMBRNC_STATUS = 'C'
        AND l_CC_APPRVL_STATUS = 'AP' THEN

        /* Get the fiscal year of the invoice */
 	BEGIN
		SELECT DISTINCT period_year
	 	INTO l_fiscal_year_invoice
		FROM gl_period_statuses
		WHERE set_of_books_id = (SELECT set_of_books_id
        		                      FROM AP_SYSTEM_PARAMETERS)
		AND l_gl_date BETWEEN START_DATE AND END_DATE;
	EXCEPTION
		WHEN OTHERS THEN
			FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
			FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
	                FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
			APP_EXCEPTION.RAISE_EXCEPTION;
	END;

        IF x_form_name = 'APXINWKB' THEN
	  /* Check whether it is the Match button(dist id is NULL) that is pressed or the Distribute button */
  	  IF x_po_dist_num IS NULL THEN

		/*Loop through each account line */
		FOR c_acct_line1 IN c_acct_line(l_cc_num)
		LOOP
			/*Loop through each of the distributions in PO */
			FOR c_for_each_dist_in_po1 IN for_each_dist_in_po(l_cc_num)
			LOOP
				/*Loop and get the pf date of only those Payment Forecast lines which
				 * have corresponding distribution line in
				 * po_distributions*/
				BEGIN
					SELECT CC_DET_PF_DATE
					INTO l_cc_det_pf_date
					FROM IGC_CC_DET_PF
					WHERE CC_acct_LINE_ID =  c_acct_line1.cc_acct_line_id
						AND cc_det_pf_line_num = c_for_each_dist_in_po1.distribution_num;

			        EXCEPTION
					WHEN OTHERS THEN
						FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
						FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
						APP_EXCEPTION.RAISE_EXCEPTION;
			        END;

				/* Get the fiscal year for the Payment Forecast Date */
				BEGIN
			   		SELECT DISTINCT period_year
		     			INTO l_fiscal_year_pf
	     				FROM gl_period_statuses
		     			WHERE set_of_books_id = (SELECT set_of_books_id
        	                	      			FROM AP_SYSTEM_PARAMETERS)
			 		AND l_CC_DET_PF_DATE BETWEEN START_DATE AND END_DATE;
			        EXCEPTION
					WHEN OTHERS THEN
						FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
						FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
						APP_EXCEPTION.RAISE_EXCEPTION;
			        END;

				/* Even if one Payment Forecast Date fiscal year does not match
					the fiscal year of the invoice stop processing and return false */
		 		IF (l_fiscal_year_invoice = l_fiscal_year_pf)  THEN
	        			l_status :=  TRUE;
			     	ELSE
	        			RETURN  FALSE;
		         	END IF;
			END LOOP;

		END LOOP;
  	ELSE
     	/* Distribute button is pressed and a specific Distribution line is being matched */
                BEGIN
		/* Get the Payment Forecast Date for that particular distribution line*/
			SELECT CC_DET_PF_DATE
     			INTO l_pf_date
     			FROM IGC_CC_DET_PF
	     		WHERE CC_acct_LINE_ID = (SELECT CC_acct_LINE_ID
			                               FROM IGC_CC_ACCT_LINES
        	        		               WHERE cc_header_id = (SELECT cc_header_id
                	                		                     FROM IGC_CC_HEADERS
                        	                        		     WHERE CC_NUM = l_cc_num)
					       		AND CC_ACCT_LINE_NUM = x_shipment_num)
    			AND CC_DET_PF_LINE_NUM = x_po_dist_num;
	        EXCEPTION
			WHEN OTHERS THEN
  				FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
				FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
		                FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
				APP_EXCEPTION.RAISE_EXCEPTION;
	        END;


		/* Get the fiscal year for the Payment Forecast Date */
		BEGIN
	     		SELECT DISTINCT period_year
	     		INTO l_fiscal_year_pf
	     		FROM gl_period_statuses
	     		WHERE set_of_books_id = (SELECT set_of_books_id
        	                                 FROM AP_SYSTEM_PARAMETERS)
	     		AND l_pf_date BETWEEN START_DATE AND END_DATE;
		     EXCEPTION
		WHEN OTHERS THEN
			FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
			FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
	                FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
			APP_EXCEPTION.RAISE_EXCEPTION;
		END;



     		IF (l_fiscal_year_invoice = l_fiscal_year_pf)  THEN
        		l_status := TRUE;
     		ELSE
        		RETURN FALSE;
     		END IF;

  	  END IF;
	  -- The function is called from Invoice Gateway form
	  --   Eight cases needs to be handled
	  --   a. Only PO number is entered so check the dates of the pf lines belonging to
	  --      each of the lines and their shipments
	  --   b. PO number and line number are entered so check the dates of the pf lines
	  --      belonging to that line number and its corresponding shipments
	  --   c. PO number,line number and shipment number is entered so check the dates of
	  --      pf lines belonging only to that shipment number and line number.
	  --   d. PO number, line number, shipment number and distribution is entered so check
	  --      date only for that specfic pf line
	  --   e. PO number and shipment number entered.
	  --   f. PO number and distribution number entered.
	  --   g. PO number, shipment number and distribution number entered.
	  --   h. PO number, line number and distribution number entered.
	ELSIF x_form_name = 'APXIISIM' THEN
	  -- Case a: Only PO number is entered so check for all the lines,shipments and distributions
          IF x_line_num IS NULL AND x_shipment_num IS NULL AND x_po_dist_num IS NULL THEN

		FOR c_get_po_line_id1 IN c_get_po_line_id(x_po_header_id)
		LOOP
			FOR c_get_shipment_num1 IN c_get_shipment_num(c_get_po_line_id1.po_line_id)
			LOOP
				FOR c_get_cc_acct_line_id1 IN c_get_cc_acct_line_id(c_get_shipment_num1.shipment_num)
				LOOP
					FOR c_get_distribution_num1 IN c_get_distribution_num(c_get_po_line_id1.po_line_id,
                                                                              c_get_shipment_num1.line_location_id)

					LOOP
						BEGIN
							SELECT cc_det_pf_date
				        		INTO l_cc_det_pf_date
							FROM igc_cc_det_pf
							WHERE cc_acct_line_id =  c_get_cc_acct_line_id1.cc_acct_line_id
							AND cc_det_pf_line_num = c_get_distribution_num1.distribution_num;
						EXCEPTION
							WHEN OTHERS THEN
								FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
								FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                		FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
								APP_EXCEPTION.RAISE_EXCEPTION;
						END;


						BEGIN
			     				SELECT DISTINCT period_year
	     						INTO l_fiscal_year_pf
			     				FROM gl_period_statuses
	     						WHERE set_of_books_id = (SELECT set_of_books_id
        	                		        		         FROM AP_SYSTEM_PARAMETERS)
			     				AND l_cc_det_pf_date BETWEEN START_DATE AND END_DATE;
	  	                		EXCEPTION
							WHEN OTHERS THEN
								FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
								FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                		FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
								APP_EXCEPTION.RAISE_EXCEPTION;
						END;

				     		IF (l_fiscal_year_invoice = l_fiscal_year_pf)  THEN
        						l_status := TRUE;
		     				ELSE
		        				RETURN FALSE;
		     				END IF;

					END LOOP;
                   		END LOOP;
			END LOOP;
            	END LOOP;

          -- Case b: Only PO number and line number is entered so check for all the shipments and its
	  -- distributions
          ELSIF x_line_num IS NOT NULL AND x_shipment_num IS NULL AND x_po_dist_num IS NULL THEN

			FOR c_get_shipment_num1 IN c_get_shipment_num(x_po_line_id)
			LOOP
				FOR c_get_cc_acct_line_id1 IN c_get_cc_acct_line_id(c_get_shipment_num1.shipment_num)
				LOOP
					FOR c_get_distribution_num1 IN c_get_distribution_num(x_po_line_id,
                                                                              c_get_shipment_num1.line_location_id)

					LOOP
						BEGIN
							SELECT cc_det_pf_date
				        		INTO l_cc_det_pf_date
							FROM igc_cc_det_pf
							WHERE cc_acct_line_id =  c_get_cc_acct_line_id1.cc_acct_line_id
							AND cc_det_pf_line_num = c_get_distribution_num1.distribution_num;
						EXCEPTION
							WHEN OTHERS THEN
								FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
								FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                		FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
								APP_EXCEPTION.RAISE_EXCEPTION;
						END;

						BEGIN
			     				SELECT DISTINCT period_year
	     						INTO l_fiscal_year_pf
			     				FROM gl_period_statuses
	     						WHERE set_of_books_id = (SELECT set_of_books_id
        	                		        		         FROM AP_SYSTEM_PARAMETERS)
			     				AND l_cc_det_pf_date BETWEEN START_DATE AND END_DATE;
	  	                		EXCEPTION
							WHEN OTHERS THEN
								FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
								FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                		FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
								APP_EXCEPTION.RAISE_EXCEPTION;
						END;


				     		IF (l_fiscal_year_invoice = l_fiscal_year_pf)  THEN
        						l_status := TRUE;
		     				ELSE
		        				RETURN FALSE;
		     				END IF;

					END LOOP;
                   		END LOOP;
			END LOOP;

          -- Cases c and e : Po number, Line number(may or may not be entered), Shipment number is entered so
	  -- check for all the distributions

          ELSIF x_shipment_num IS NOT NULL AND x_po_dist_num IS NULL THEN

				FOR c_get_cc_acct_line_id1 IN c_get_cc_acct_line_id(x_shipment_num)
				LOOP
					FOR c_get_distribution_num1 IN c_get_distribution_num(x_po_line_id,
                                                                              x_line_location_id)

					LOOP
						BEGIN
							SELECT cc_det_pf_date
				        		INTO l_cc_det_pf_date
							FROM igc_cc_det_pf
							WHERE cc_acct_line_id =  c_get_cc_acct_line_id1.cc_acct_line_id
							AND cc_det_pf_line_num = c_get_distribution_num1.distribution_num;
						EXCEPTION
							WHEN OTHERS THEN
								FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
								FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                		FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
								APP_EXCEPTION.RAISE_EXCEPTION;
						END;

						BEGIN
			     				SELECT DISTINCT period_year
	     						INTO l_fiscal_year_pf
			     				FROM gl_period_statuses
	     						WHERE set_of_books_id = (SELECT set_of_books_id
        	                		        		         FROM AP_SYSTEM_PARAMETERS)
			     				AND l_cc_det_pf_date BETWEEN START_DATE AND END_DATE;
	  	                		EXCEPTION
							WHEN OTHERS THEN
								FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
								FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                		FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
								APP_EXCEPTION.RAISE_EXCEPTION;
						END;

				     		IF (l_fiscal_year_invoice = l_fiscal_year_pf)  THEN
        						l_status := TRUE;
		     				ELSE
		        				RETURN FALSE;
		     				END IF;

					END LOOP;
                   		END LOOP;

          -- Cases d, f, g and h:
          ELSIF x_po_dist_num IS NOT NULL THEN

		l_shipment_num := x_shipment_num;

		IF x_shipment_num IS NULL THEN
	  		BEGIN
			        SELECT line_location_id
				INTO l_line_location_id
				FROM po_distributions
				WHERE po_distribution_id = x_po_distribution_id;


				SELECT shipment_num
				INTO l_shipment_num
			        FROM po_line_locations
				WHERE line_location_id = l_line_location_id;
               		EXCEPTION
				WHEN OTHERS THEN
					FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
					FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
	                		FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
					APP_EXCEPTION.RAISE_EXCEPTION;
			END;

		END IF;

				FOR c_get_cc_acct_line_id1 IN c_get_cc_acct_line_id(l_shipment_num)
				LOOP
						BEGIN
							SELECT cc_det_pf_date
				        		INTO l_cc_det_pf_date
							FROM igc_cc_det_pf
							WHERE cc_acct_line_id =  c_get_cc_acct_line_id1.cc_acct_line_id
							AND cc_det_pf_line_num = x_po_dist_num;
						EXCEPTION
							WHEN OTHERS THEN
								FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
								FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                		FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
								APP_EXCEPTION.RAISE_EXCEPTION;
						END;

						BEGIN
			     				SELECT DISTINCT period_year
	     						INTO l_fiscal_year_pf
			     				FROM gl_period_statuses
	     						WHERE set_of_books_id = (SELECT set_of_books_id
        	                		        		         FROM AP_SYSTEM_PARAMETERS)
			     				AND l_cc_det_pf_date BETWEEN START_DATE AND END_DATE;
	  	                		EXCEPTION
							WHEN OTHERS THEN
								FND_MESSAGE.SET_NAME('IGC', 'IGC_LOGGING_UNEXP_ERROR');
								FND_MESSAGE.SET_TOKEN('CODE', SQLCODE);
				                		FND_MESSAGE.SET_TOKEN('MSG', SQLERRM);
								APP_EXCEPTION.RAISE_EXCEPTION;
						END;

				     		IF (l_fiscal_year_invoice = l_fiscal_year_pf)  THEN
        						l_status := TRUE;
		     				ELSE
		        				RETURN FALSE;
		     				END IF;

			END LOOP;

		END IF;
	END IF;

     END IF;
  RETURN TRUE;

END DATE_IS_VALID;

/*=======================================================================+
 |                      FUNCTION XML_REPORT_ENABLED
 |                                                                       |
 | Note : This function is designed to decide if the xml report(s) is    |
 |        to be triggered or not. Presently it returns true. In future   |
 |        the function can be modified to incorporate profile options    |
	  and return true/false based on conditions.                     |
 +=======================================================================*/

FUNCTION XML_REPORT_ENABLED
  RETURN BOOLEAN
  IS
     BEGIN
        RETURN FALSE;
END XML_REPORT_ENABLED;

/*=======================================================================+
 |                      PROCEDURE GET_XML_LAYOUT_INFO
 |                                                                       |
 | Note : This procedure is designed to get layout information of the    |
 |        xml report that is to be generated.                            |
 |									 |
 | Parameters :                                                          |
 |                                                                       |
 |   p_lang                     Language, takes the default value        |
 |                              when no value is obtained                |
 |   p_terr                     Territory, takes the default value       |
 |                              when no value is obtained                |
 |   p_lob_code                 BiPubllisher Code for the XML Report     |
 |   p_application_short_name   Short Name of the Application            |
 |   p_template_code            Template Code for the XML Report         |
 +=======================================================================*/

PROCEDURE GET_XML_LAYOUT_INFO(
    p_lang                   IN OUT NOCOPY VARCHAR2,
    p_terr                   IN OUT NOCOPY VARCHAR2,
    p_lob_code               IN VARCHAR2,
    p_application_short_name IN VARCHAR2,
    p_template_code          IN VARCHAR2
)
   IS
      ls_lang  VARCHAR2(10);
      v_cnt    NUMBER;
      l_lang   VARCHAR2(10);
      CURSOR xml_cur
         IS
	    SELECT LANGUAGE,
	    	   TERRITORY
	    FROM XDO_LOBS
	    WHERE LOB_CODE = p_lob_code
	    AND APPLICATION_SHORT_NAME = p_application_short_name
	    AND (LOB_TYPE              = 'TEMPLATE'
	    OR LOB_TYPE                = 'MLS_TEMPLATE')
	    AND LANGUAGE               = p_lang
	    AND XDO_FILE_TYPE          = 'XSL-FO';
   BEGIN
      SELECT SUBSTR(userenv('LANG'),1,4) INTO ls_lang FROM dual;
      IF ls_lang = 'US' THEN
	p_lang  := 'en' ;
      ELSE
	p_lang := lower(ls_lang);
      END IF;
      OPEN xml_cur;
      	FETCH xml_cur INTO l_lang,p_terr;
	v_cnt := xml_cur%rowcount;
      CLOSE xml_cur;
      IF v_cnt = 0 THEN
	      SELECT default_language,
	             default_territory
	      INTO   l_lang,
	             p_terr
	      FROM   XDO_TEMPLATES_B
              WHERE TEMPLATE_CODE = p_template_code
              AND APPLICATION_SHORT_NAME = p_application_short_name ;
      END IF;
      l_lang := p_lang;
END GET_XML_LAYOUT_INFO;



END IGC_CC_COMMON_UTILS_PVT;


/
