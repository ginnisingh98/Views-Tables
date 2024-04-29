--------------------------------------------------------
--  DDL for Package Body IGI_CIS_UPDC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS_UPDC" AS
/* $Header: igicisdb.pls 115.15 2003/12/17 13:36:28 hkaniven noship $  */


  p_effective_date DATE;


  l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
  l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
  l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
  l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
  l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
  l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
  l_path        VARCHAR2(50)  :=  'IGI.PLSQL.igicisdb.IGI_CIS_UPDC.';


  /*PROCEDURE WriteLog ( pp_mesg in varchar2 , pp_debug_mode in boolean := FALSE ) IS
  BEGIN
          IF pp_debug_mode THEN
                Fnd_file.put_line(fnd_file.log,'============================================================' );
                Fnd_file.put_line( fnd_file.log , pp_mesg ) ;
          ELSE
                Null;
          END IF;
  END; */


  PROCEDURE Debug    ( p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2  ) is
   BEGIN
	IF (p_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (p_level , l_path || p_path , p_mesg );
        END IF;
   END ;


  PROCEDURE  Validate_dates (p_cert_start_date IN  DATE
                             ,p_cert_end_date   IN  DATE
                             ,p_effective_date  IN  DATE
                             ,p_cur_start_date  OUT NOCOPY DATE
                             ,p_cur_end_date    OUT NOCOPY DATE
                             ,p_new_start_date  OUT NOCOPY DATE
                             ,p_new_end_date    OUT NOCOPY DATE
                             ,p_special_case    OUT NOCOPY BOOLEAN) IS
                             l_message varchar2(100);
  BEGIN
           p_special_case := FALSE;


           /*  Effective date between start and end dates  */

           IF  p_cert_start_date  <  p_effective_date AND
              (p_cert_end_date    >=  p_effective_date   OR p_cert_end_date IS NULL)
           THEN

               p_cur_start_date :=  p_cert_start_date;
               p_cur_end_date   :=  p_effective_date - 1;
               p_new_start_date :=  p_effective_date;
               p_new_end_date   :=  p_cert_end_date;
           END IF;

           /* Effective date equal to start date and both are not null */

           IF p_cert_end_date   IS NOT NULL AND
              p_cert_start_date = p_effective_date AND
              p_cert_end_date   > p_effective_date
           THEN
               p_cur_start_date := p_effective_date;
               p_cur_end_date   := p_cert_end_date;
               p_new_start_date :=  null ; --p_effective_date ;
               p_new_end_date   :=  null ; --p_cert_end_date;

           END IF;


           /*  Effective date equal to start date equal to end date */


           IF p_cert_start_date IS NOT NULL AND
              p_cert_end_date   IS NOT NULL AND
              p_cert_start_date = p_effective_date AND
              p_cert_end_date   = p_effective_date
           THEN
   	          p_special_case   := TRUE;

           END IF;


  END validate_dates;

  PROCEDURE GENERATE_TAX_RATE_ID (p_tax_rate_id OUT NOCOPY NUMBER) IS
  CURSOR c_gen_id IS
        SELECT ap_awt_tax_rates_s.NEXTVAL FROM   SYS.DUAL;
        INVALIDSEQ Exception;
        l_message varchar2(100) ;
   BEGIN
        OPEN c_gen_id;
        FETCH c_gen_id INTO p_tax_rate_id;
        IF c_gen_id%NOTFOUND THEN
	   Raise  INVALIDSEQ;
        END IF;
        CLOSE c_gen_id;
    EXCEPTION
        WHEN INVALIDSEQ  THEN
		Fnd_message.set_name('IGI','IGI_CIS_MISSING_SEQ');
		l_message:=fnd_message.get;
		Debug(l_excep_level, 'GENERATE_TAX_RATE_ID', l_message);

  END GENERATE_TAX_RATE_ID;

  PROCEDURE upd_cis_cert_type_perc ( Retcode OUT NOCOPY NUMBER ,
                       Errbuf  OUT NOCOPY VARCHAR2 ,
                      P_mode VARCHAR2,
	              P_current_certificate_type VARCHAR2,
		      P_effective_date1 VARCHAR2,
		      P_new_percentage  NUMBER := NULL,
		      P_new_certificate_type VARCHAR2  := NULL

			  ) IS


    /*cursor to select awt data for updation*/

    CURSOR c_certificate IS
        SELECT rowid ,
               tax_rate_id ,
               tax_name,
               tax_rate,
               rate_type,
               start_date,
               end_date,
               start_amount,
               end_amount,
               last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               vendor_id,
               vendor_site_id,
               invoice_num,
               certificate_number,
               certificate_type,
               comments,
               priority,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               org_id
       FROM ap_awt_tax_rates
       WHERE  tax_name = IGI_CIS_GET_PROFILE.Cis_Tax_Code
       AND certificate_type = p_current_certificate_type ;

    CURSOR  c1 ( c_tax_rate_id  number )IS
    SELECT tax_rate_id , ni_number
    FROM igi_cis_cert_ni_numbers
    WHERE TAX_RATE_ID = c_tax_rate_id ;


    CURSOR  c2 (c_start_date date, c_end_date date , c_vendor_id number , c_tax_rate_id number  )  is
    SELECT   'X' from ap_awt_tax_rates
    WHERE  tax_name = IGI_CIS_GET_PROFILE.Cis_Tax_Code
    AND	((certificate_type = decode(p_mode , 'Percentages' ,  p_current_certificate_type , p_new_certificate_type)) OR (certificate_type = p_current_certificate_type))
    AND vendor_id = c_vendor_id
    AND tax_rate_id <> c_tax_rate_id
    AND	( ( start_date  <=  c_start_date AND end_date  >= c_end_date) OR
             (start_date >= c_start_date AND  end_date <= c_end_date) OR
             (c_start_date BETWEEN start_date AND end_date) OR
             (c_end_date BETWEEN start_date AND end_date) )   ;

    CURSOR C3  (c_vendor_id  number )IS
    SELECT vendor_name  FROM po_vendors
    WHERE vendor_id = c_vendor_id ;

    CURSOR C4(c_vendor_site_id  number , c_org_id number , c_vendor_id number) IS
    SELECT  vendor_site_code  FROM po_vendor_sites
    WHERE vendor_site_id = c_vendor_site_id
    AND org_id = c_org_id
    AND vendor_id = c_vendor_id;

       l3 c3%rowtype;
       l4 c4%rowtype;
       l_message varchar2(1000);
       l_row_id varchar2  (30);
       l_tax_rate_id number;
       l1 c1%rowtype;
       l2 c2%rowtype;
       l_certificate c_certificate%rowtype;
       l_curr_start_date date;
       l_curr_end_date date;
       l_new_start_date date;
       l_new_end_date date;
       l_special_case boolean := FALSE;
       l_vendor_site_code varchar2(15);
       l_vendor_name po_vendors.vendor_name%TYPE;
     --l_vendor_name varchar2(240) ;UTF changes Bug No. 2524214
       l_tax_rate number ;
       l_certificate_type varchar2(25);
       l_vendor_site varchar2(100) ;
       l_call_seq varchar2(100) ;

       /* Bug 3085887 rgopalan 7-AUG-2003 */
       /* This needs to be removed for 11ix MOAC */
       l_org_id number := FND_PROFILE.VALUE('ORG_ID');

       l_changed boolean := FALSE ;

       UNPROCESSED Exception ;
       INEXISTENT Exception ;
       INVALID   Exception;

   BEGIN

 p_effective_date:=to_date(p_effective_date1,'YYYY/MM/DD HH24:MI:SS');

     /*Checking the modes and corresponding parameters*/



   IF p_mode = 'Percentages' THEN
	IF (p_new_percentage IS NULL ) THEN
		Raise INVALID;

  	END IF;

  	IF (p_new_certificate_type IS NOT NULL ) THEN

  	        Fnd_message.set_name('IGI','IGI_CIS_VALUES_NOT_MATCH');
		Fnd_message.set_token('mode', p_mode);
		Fnd_message.set_token('other_mode', 'Certificate Type' );
		l_message:=Fnd_message.get;
          	Debug(l_state_level, 'upd_cis_cert_type_perc.msg1', l_message);
	END IF;

   ELSE   /*else for p_mode*/
        IF p_new_certificate_type IS NULL THEN
		Raise INVALID;
        END IF;
        IF (p_new_percentage IS NOT NULL ) THEN

  	        Fnd_message.set_name('IGI','IGI_CIS_VALUES_NOT_MATCH');
		Fnd_message.set_token('mode', p_mode);
		Fnd_message.set_token('other_mode', 'Percentage' );
		l_message:=Fnd_message.get;
        	Debug(l_state_level, 'upd_cis_cert_type_perc.msg2', l_message);
	END IF;
   END IF;


           /*Finish checking the modes and corresponding parameters*/


   OPEN c_certificate;
   FETCH c_certificate INTO l_certificate;
   IF c_certificate%NOTFOUND THEN
	Raise  INEXISTENT;
   END IF;
    CLOSE c_certificate;
    /*Start Processing*/
    /*Loop for all  the values selected*/

    FOR l_certificate IN c_certificate

    LOOP  ------------------------------------------ For Loop----- Starts-

    BEGIN




    IF ( ( (l_certificate.end_date >=p_effective_date ) OR (l_certificate.end_date IS NULL ))  AND l_certificate.start_date <= p_effective_date) THEN

           validate_dates (l_certificate.start_date
                         ,l_certificate.end_date
                         ,p_effective_date
                         ,l_curr_start_date
                         ,l_curr_end_date
                         ,l_new_start_date
                         ,l_new_end_date
                         ,l_special_case);
    END IF;



         /*  Update /Insert  in case the date does not fall under the special case>  */

    IF   NOT (l_special_case) THEN    ------------------------------------------------------------(1)


          OPEN c3 (l_certificate.vendor_id);
          FETCH c3 INTO l3;
          CLOSE c3;
          l_vendor_name := l3.vendor_name ;


          OPEN c4 (l_certificate.vendor_site_id ,l_certificate.org_id  , l_certificate.vendor_id );
          FETCH c4 INTO l4;
          CLOSE c4;
          l_vendor_site_code := l4.vendor_site_code ;



          OPEN c2(l_certificate.start_date,l_certificate.end_date ,l_certificate.vendor_id , l_certificate.tax_rate_id);
          FETCH c2 INTO l2;



          IF c2%NOTFOUND THEN    -------------------------------------------------------------(2)


          /* The Certificate does not have overlapaping dates*/


               IF p_mode = 'Percentages' THEN
                      l_tax_rate   :=  p_new_percentage;
                      l_certificate_type := l_certificate.certificate_type;
               ELSE
                      l_tax_rate:=L_certificate.tax_rate;
                      l_certificate_type:=p_new_certificate_type;
               END IF;

        /* End of mode analysis*/
        /* To update old record and  insert in case  of breaking an existing period */

                   IF ( ((l_certificate.end_date  >= p_effective_date) OR (l_certificate.end_date IS NULL )) and l_certificate.start_date <  p_effective_date) THEN ---------(3)

                      Generate_tax_rate_id(l_tax_rate_id);


                      UPDATE   ap_awt_tax_rates
                      SET   end_date = l_curr_end_date
                      WHERE rowid = l_certificate.rowid;

                        Fnd_message.set_name('IGI','IGI_CIS_UPDATED_CERT');
			Fnd_message.set_token('vendor_name',l_vendor_name);
			Fnd_message.set_token('vendor_site',l_vendor_site_code);
			Fnd_message.set_token('tax_group', IGI_CIS_GET_PROFILE. Cis_Tax_group);
			Fnd_message.set_token('tax_name',l_certificate.tax_name);
			Fnd_message.set_token('cert_type',l_certificate.certificate_type);
			Fnd_message.set_token('cert_number',l_certificate.certificate_number);
      			Fnd_message.set_token ('tax_rate',l_certificate.tax_rate ) ;
      			Fnd_message.set_token('eff_from_date',l_certificate.start_date);
      			Fnd_message.set_token('eff_to_date',l_curr_end_date);
      			l_message:=Fnd_message.get;
	        	Debug(l_state_level, 'upd_cis_cert_type_perc', l_message);

      			  IF  ((p_new_certificate_type = 'CIS4P' OR  p_new_certificate_type = 'CIS6') and (p_mode = 'Types'))  THEN   ---------------------(61)

		              Fnd_message.set_name( 'IGI','IGI_CIS_NI_NUMBER_REQ') ;
		              l_message:=Fnd_message.get;
	        	      Debug(l_state_level, 'upd_cis_cert_type_perc', l_message);
		          END IF; -------------------------------------(61)



               INSERT INTO ap_awt_tax_rates
                   (tax_rate_id,
                    tax_name,
                    tax_rate,
                    rate_type,
                    start_date,
                    end_date,
                    start_amount,
                    end_amount,
                    last_update_date,
                    last_updated_by,
                    last_update_login,
                    creation_date,
                    created_by,
                    vendor_id,
                    vendor_site_id,
                    invoice_num,
                    certificate_number,
                    certificate_type,
                    comments,
                    priority,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    org_id)
               VALUES
                   (l_tax_rate_id,
                    l_certificate.tax_name,
                    l_tax_rate,
                    l_certificate.rate_type,
                    l_new_start_date,
                    l_new_end_date,
                    l_certificate.start_amount,
                    l_certificate.end_amount,
	            sysdate,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    sysdate ,
                    fnd_global.user_id,
                    l_certificate.vendor_id,
                    l_certificate.vendor_site_id,
                    l_certificate.invoice_num,
                    l_certificate.certificate_number,
                    l_certificate_type,
                    l_certificate.comments,
                    l_certificate.priority,
                    l_certificate.attribute_category,
                    l_certificate.attribute1,
                    l_certificate.attribute2,
                    l_certificate.attribute3,
                    l_certificate.attribute4,
                    l_certificate.attribute5,
                    l_certificate.attribute6,
                    l_certificate.attribute7,
                    l_certificate.attribute8,
                    l_certificate.attribute9,
                    l_certificate.attribute10,
                    l_certificate.attribute11,
                    l_certificate.attribute12,
                    l_certificate.attribute13,
                    l_certificate.attribute14,
                    l_certificate.attribute15,
                    l_certificate.org_id);

                        Fnd_message.set_name('IGI','IGI_CIS_UPDATED_CERT');
                        Fnd_message.set_token('vendor_name',l_vendor_name);
			Fnd_message.set_token('vendor_site',l_vendor_site_code);
			Fnd_message.set_token('tax_group', IGI_CIS_GET_PROFILE.Cis_Tax_group);
			Fnd_message.set_token('tax_name',l_certificate.tax_name);
			Fnd_message.set_token('cert_type',l_certificate_type);
			Fnd_message.set_token('cert_number' ,l_certificate.certificate_number);
			Fnd_message.set_token('tax_rate' ,l_tax_rate);
			Fnd_message.set_token('eff_from_date',l_new_start_date);
			Fnd_message.set_token('eff_to_date',l_new_end_date);
			L_message:=Fnd_message.get;
		        Debug(l_state_level, 'upd_cis_cert_type_perc.msg1', l_message);

		/*  Prepare a new record  for the new percentage/new certificate type */

                      SELECT rowid into l_row_id FROM ap_awt_tax_rates WHERE  tax_rate_id=l_tax_rate_id ;
                /* Modified the cursor parameter value to take the old tax rate id for retrieving the ni number
                       instead of the current tax rate id Bug 2443964 solakshm*/
                      OPEN c1(l_certificate.tax_rate_id);
                      FETCH c1 INTO l1;
                      CLOSE c1;
                      l_call_seq := 'CIS :Update Certificate Percentages' ;

                /* table handler for igi_cis_cert_ni_numbers_all */

                      igi_cis_cert_ni_numbers_pkg.insert_row
                                    (l_row_id
                                    ,l_org_id  /* Bug 3085887 11.5.10 MOAC change */
                                    ,l_tax_rate_id
                                    ,l1.ni_number
                                    ,sysdate
                                    ,fnd_global.user_id
                  	            ,sysdate
                                    ,fnd_global.user_id
                                    ,fnd_global.login_id
                                    ,l_call_seq );

		END IF; ------------------------------------------------------------------------------------(3)


		/* End of insert into ap_awt_tax_rates and igi_cis_ni_numbers_all*/

		/* If the effective date does not break  a period then update the certificate for future active certificates*/

			IF    l_certificate.start_date >= p_effective_date THEN    ------------------------(4)


				UPDATE  ap_awt_tax_rates
				SET     tax_rate = l_tax_rate,
				           Certificate_type= l_certificate_type
				WHERE rowid= l_certificate.rowid;




                                Fnd_message.set_name('IGI','IGI_CIS_UPDATED_CERT');

		                Fnd_message.set_token('vendor_name',l_vendor_name);
                  		Fnd_message.set_token('vendor_site' ,l_vendor_site_code);
                		Fnd_message.set_token('tax_group', IGI_CIS_GET_PROFILE. Cis_Tax_group);
                		Fnd_message.set_token('tax_name',l_certificate.tax_name);
                  		Fnd_message.set_token( 'cert_type',l_certificate_type);
                  		Fnd_message.set_token( 'cert_number',l_certificate.certificate_number);
                 		Fnd_message.set_token('tax_rate',l_tax_rate);
                 		Fnd_message.set_token('eff_from_date',l_certificate.start_date);
                 		Fnd_message.set_token('eff_to_date',l_certificate.end_date);
                      	        l_message  :=  Fnd_message.get;
                  		Debug(l_state_level, 'upd_cis_cert_type_perc.msg2', l_message);

                  		IF  ( (p_new_certificate_type = 'CIS4P' OR  p_new_certificate_type = 'CIS6' ) and ( p_mode = 'Types' )) THEN   ---------------------(62)
		                      Fnd_message.set_name( 'IGI','IGI_CIS_NI_NUMBER_REQ') ;
			              L_message:=fnd_message.get;
			              Debug(l_state_level, 'upd_cis_cert_type_perc', l_message);
		                 END IF; -------------------------------------(62)


			END IF;	   --------------------------------------------------------------------------(4)

		/* End of Update*/





   	ELSE  /* Overlapping Certificates found*/    --------------------------------------------------------(2)

   	close c2;

	         RAISE UNPROCESSED;

	END IF;     ------------------------------------------------------------------------------------------(2)

	/* End of c2%NOT FOUND*/


             close c2;

      ELSE     ------------------------------------------------------------------------------------------------(1)

                  raise UNPROCESSED;


      END IF;  ----------------------------------------------------------------------------------------------(1)

   /* not a special case*/

   EXCEPTION

   WHEN  UNPROCESSED THEN
	        Fnd_message.set_name('IGI','IGI_CIS_REC_NOT_PROCESSED');
		Fnd_message.set_token('vendor_name',l_vendor_name);
		Fnd_message.set_token('vendor_site',l_vendor_site_code);
		Fnd_message.set_token('tax_group', IGI_CIS_GET_PROFILE. Cis_Tax_group);
		Fnd_message.set_token('tax_name',l_certificate.tax_name);
		Fnd_message.set_token('cert_type',l_certificate.certificate_type);
		Fnd_message.set_token('cert_number' ,l_certificate.certificate_number);
		Fnd_message.set_token('tax_rate',l_certificate.tax_rate);
		Fnd_message.set_token('eff_from_date', l_certificate.start_date);
		fnd_message.set_token('eff_to_date',l_certificate.end_date);
	        L_message:=fnd_message.get;
	        Debug(l_excep_level, 'upd_cis_cert_type_perc', l_message);

  end ;

  End loop ;


EXCEPTION

WHEN   INEXISTENT THEN
	Fnd_message.set_name('IGI', 'IGI_CIS_REC_NOT_EXISTS');
	L_message:=fnd_message.get;
	Debug(l_excep_level, 'upd_cis_cert_type_perc', l_message);
WHEN INVALID THEN
	Fnd_message.set_name('IGI','IGI_CIS_INVALID_ARGS');
	L_message:=fnd_message.get;
	Debug(l_excep_level, 'upd_cis_cert_type_perc', l_message);
END upd_cis_cert_type_perc ;

END IGI_CIS_UPDC;

/
