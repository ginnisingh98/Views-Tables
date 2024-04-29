--------------------------------------------------------
--  DDL for Package Body IBY_EXT_PAYEE_RELSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EXT_PAYEE_RELSHIPS_PKG" AS
/*$Header: ibyprelb.pls 120.4.12010000.9 2009/04/23 13:10:49 bkjain noship $*/


	/* Debug logging procedure*/
        PROCEDURE print_debuginfo(
	   p_message_text	IN varchar2
	   )
	 IS
	BEGIN
	    iby_debug_pub.add(	debug_msg => p_message_text,
				debug_level => FND_LOG.LEVEL_STATEMENT,
				module => 'IBY_EXT_PAYEE_RELSHIPS_PKG');
	END print_debuginfo;


	/* Default Relationship
	 *  For defaulting relationship between a supplier
	 *  a remit-to-supplier
	 */
	PROCEDURE default_Ext_Payee_Relationship (
	   p_party_id IN  NUMBER,
	   p_supplier_site_id IN NUMBER,
	   p_date IN DATE,
	   x_remit_party_id IN OUT NOCOPY NUMBER,
	   x_remit_supplier_site_id IN OUT NOCOPY NUMBER,
	   x_relationship_id	IN OUT NOCOPY NUMBER
	  ) IS
	BEGIN

	   print_debuginfo('Enter : default_Ext_Payee_Relationship ');

	SELECT
	  relationship_id,
	  remit_party_id,
	  remit_supplier_site_id
	INTO
	  x_relationship_id,
	  x_remit_party_id,
	  x_remit_supplier_site_id
	FROM iby_ext_payee_relationships irel
	WHERE party_id = p_party_id
	 AND supplier_site_id = p_supplier_site_id
	 AND primary_flag = 'Y'
	 AND active = 'Y'
	 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
	 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

	   print_debuginfo('Exit : default_Ext_Payee_Relationship ');

	   EXCEPTION
	    WHEN OTHERS THEN
	      x_relationship_id := -1;
	      x_remit_party_id := null;
	      x_remit_supplier_site_id := null;
	      print_debuginfo('Default relationship not found !');
	      print_debuginfo('Exit : default_Ext_Payee_Relationship ');

	END default_Ext_Payee_Relationship;


	/*
	 * Public Defaulting Relationship for AP's Import Interface
	 */

	PROCEDURE import_Ext_Payee_Relationship (
	   p_party_id IN  NUMBER,
	   p_supplier_site_id IN NUMBER,
	   p_date IN DATE,
	   x_result  IN OUT NOCOPY VARCHAR2,
	   x_remit_party_id IN OUT NOCOPY NUMBER,
	   x_remit_supplier_site_id IN OUT NOCOPY NUMBER,
	   x_relationship_id	IN OUT NOCOPY NUMBER
	  ) IS
	   p_count  NUMBER;
	BEGIN

	   print_debuginfo('Enter : import_Ext_Payee_Relationship ');
	   print_debuginfo('Input Parameters : p_party_id,p_supplier_site_id,p_date');
	   print_debuginfo('Input Values : ' || p_party_id ||',' || p_supplier_site_id ||',' || p_date );

	IF ( (p_party_id = x_remit_party_id AND p_supplier_site_id IS NULL) OR
	     (p_party_id IS NULL AND p_supplier_site_id = x_remit_supplier_site_id) OR
	     (p_party_id = x_remit_party_id AND p_supplier_site_id = x_remit_supplier_site_id) ) THEN
		      print_debuginfo('0 Trading Partner and Remit to Supplier are same');
		      x_result := FND_API.G_TRUE ;
		      x_relationship_id := -1;
		      x_remit_party_id := p_party_id;
		      x_remit_supplier_site_id := p_supplier_site_id;
	              print_debuginfo('0 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('0 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );
        -- RELATIONSHIP ID IS NOT PROVIDED
	ELSIF ( (x_relationship_id IS NULL or x_relationship_id = -1) AND x_remit_party_id IS NULL AND x_remit_supplier_site_id IS NULL) THEN
	     BEGIN

		print_debuginfo('Relationship ID is NOT provided');
		print_debuginfo('1 Remit-To-Supplier and Remit-To-Supplier Site are not provided');

		SELECT
		  relationship_id,
		  remit_party_id,
		  remit_supplier_site_id
		INTO
		  x_relationship_id,
		  x_remit_party_id,
		  x_remit_supplier_site_id
		FROM iby_ext_payee_relationships irel
		WHERE party_id = p_party_id
		 AND supplier_site_id = p_supplier_site_id
		 AND active = 'Y'
		 AND primary_flag = 'Y'
		 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
		 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

		 x_result := FND_API.G_TRUE ;

		   EXCEPTION
		    WHEN OTHERS THEN
		      print_debuginfo('1 Primary Relationship not found');
		      x_result := FND_API.G_TRUE ;
		      x_relationship_id := -1;
		      x_remit_party_id := null;
                      x_remit_supplier_site_id := null;
	              print_debuginfo('1 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('1 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );

	    END;
	ELSIF ( (x_relationship_id IS NULL or x_relationship_id = -1) AND x_remit_party_id IS NULL AND NOT (x_remit_supplier_site_id IS NULL)) THEN
	     BEGIN

		print_debuginfo('Relationship ID is NOT provided');
		print_debuginfo('2 Remit-To-Supplier is not provided');
		SELECT
		  relationship_id,
		  remit_party_id
		INTO
		  x_relationship_id,
		  x_remit_party_id
		FROM iby_ext_payee_relationships irel
		WHERE party_id = p_party_id
		 AND supplier_site_id = p_supplier_site_id
		 AND remit_supplier_site_id = x_remit_supplier_site_id
		 AND active = 'Y'
		 AND primary_flag = 'Y'
		 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
		 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

		 x_result := FND_API.G_TRUE ;

		   EXCEPTION
		    WHEN OTHERS THEN
		    IF (x_remit_supplier_site_id <> p_supplier_site_id ) THEN

		      print_debuginfo('2 Primary Relationship not found');
			SELECT count(*)
			INTO p_count
			FROM iby_ext_payee_relationships irel
			WHERE party_id = p_party_id
			 AND supplier_site_id = p_supplier_site_id
			 AND remit_supplier_site_id = x_remit_supplier_site_id
			 AND active = 'Y'
			 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
			 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));
		      END IF;

		      IF (( p_count > 0) OR (x_remit_supplier_site_id = p_supplier_site_id) ) THEN
		              print_debuginfo('2 Secondary Relationship found');
			      x_result := FND_API.G_TRUE ;
		      ELSE
		              print_debuginfo('2 Secondary Relationship not found');
			      x_result := FND_API.G_FALSE ;
		      END IF;

		      IF( p_count = 1) THEN
                            SELECT irel.relationship_id,irel.remit_party_id,irel.remit_supplier_site_id
                            INTO  x_relationship_id, x_remit_party_id, x_remit_supplier_site_id
                            FROM iby_ext_payee_relationships irel
                            WHERE irel.party_id = p_party_id
                            AND irel.supplier_site_id = p_supplier_site_id
                            AND irel.remit_supplier_site_id = x_remit_supplier_site_id
                            AND active = 'Y'
                            AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
			    AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));
                        print_debuginfo('2 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                        print_debuginfo('2 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );
		      ELSE
                      x_relationship_id := -1;
		      x_remit_party_id := null;
                      x_remit_supplier_site_id := null;
	              print_debuginfo('2 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('2 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );
                      END IF;


	    END;
	ELSIF ( (x_relationship_id IS NULL or x_relationship_id = -1) AND NOT(x_remit_party_id IS NULL) AND x_remit_supplier_site_id IS NULL) THEN
	     BEGIN

		print_debuginfo('Relationship ID is NOT provided');
		print_debuginfo('3 Remit-To-Supplier Site is not provided');
		SELECT
		  relationship_id,
		  remit_supplier_site_id
		INTO
		  x_relationship_id,
		  x_remit_supplier_site_id
		FROM iby_ext_payee_relationships irel
		WHERE party_id = p_party_id
		 AND supplier_site_id = p_supplier_site_id
		 AND remit_party_id = x_remit_party_id
		 AND active = 'Y'
		 AND primary_flag = 'Y'
		 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
		 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

		 x_result := FND_API.G_TRUE ;

		   EXCEPTION
		    WHEN OTHERS THEN
		      print_debuginfo('3 Primary Relationship not found');
		      IF ( x_remit_party_id <> p_party_id ) THEN
			SELECT count(*)
			INTO p_count
			FROM iby_ext_payee_relationships irel
			WHERE party_id = p_party_id
			 AND supplier_site_id = p_supplier_site_id
			 AND remit_party_id = x_remit_party_id
			 AND active = 'Y'
			 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
			 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));
		      END IF;

		      IF ( (p_count > 0 ) OR ( x_remit_party_id = p_party_id)) THEN
		              print_debuginfo('3 Secondary Relationship found');
			      x_result := FND_API.G_TRUE ;
		      ELSE
		              print_debuginfo('3 Secondary Relationship not found');
			      x_result := FND_API.G_FALSE ;
		      END IF;

		      IF( p_count = 1) THEN
                            SELECT irel.relationship_id,irel.remit_party_id,irel.remit_supplier_site_id
                            INTO  x_relationship_id, x_remit_party_id, x_remit_supplier_site_id
                            FROM iby_ext_payee_relationships irel
                            WHERE irel.party_id = p_party_id
                            AND irel.supplier_site_id = p_supplier_site_id
                            AND irel.remit_party_id = x_remit_party_id
                            AND active = 'Y'
                            AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
			    AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));
                      print_debuginfo('3 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('3 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );
		      ELSE
                      x_relationship_id := -1;
		      x_remit_party_id := null;
                      x_remit_supplier_site_id := null;
	              print_debuginfo('3 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('3 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );
                      END IF;

	    END;
	ELSIF ( (x_relationship_id IS NULL or x_relationship_id = -1) AND NOT(x_remit_party_id IS NULL) AND NOT(x_remit_supplier_site_id IS NULL) ) THEN
	     BEGIN

		print_debuginfo('Relationship ID is NOT provided');
		print_debuginfo('4 Remit-To-Supplier and Remit-To-Supplier Site are provided');

		SELECT
		  relationship_id
		INTO
		  x_relationship_id
		FROM iby_ext_payee_relationships irel
		WHERE party_id = p_party_id
		 AND supplier_site_id = p_supplier_site_id
		 AND remit_party_id = x_remit_party_id
		 AND remit_supplier_site_id = x_remit_supplier_site_id
		 AND active = 'Y'
		 AND primary_flag = 'Y'
		 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
		 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

		 x_result := FND_API.G_TRUE ;

		   EXCEPTION
		    WHEN OTHERS THEN
		      print_debuginfo('4 Primary Relationship not found');

			SELECT count(*)
			INTO p_count
			FROM iby_ext_payee_relationships irel
			WHERE party_id = p_party_id
			 AND supplier_site_id = p_supplier_site_id
			 AND remit_party_id = x_remit_party_id
			 AND remit_supplier_site_id = x_remit_supplier_site_id
			 AND active = 'Y'
			 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
			 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

		      IF ( p_count > 0 ) THEN
		              print_debuginfo('4 Secondary Relationship found');
			      x_result := FND_API.G_TRUE ;
		      ELSE
		              print_debuginfo('4 Secondary Relationship not found');
			      x_result := FND_API.G_FALSE ;
		      END IF;

                      IF( p_count = 1) THEN
                            SELECT irel.relationship_id,irel.remit_party_id,irel.remit_supplier_site_id
                            INTO  x_relationship_id, x_remit_party_id, x_remit_supplier_site_id
                            FROM iby_ext_payee_relationships irel
                            WHERE irel.party_id = p_party_id
                            AND irel.supplier_site_id = p_supplier_site_id
                            AND irel.remit_party_id = x_remit_party_id
                            AND irel.remit_supplier_site_id = x_remit_supplier_site_id
                            AND active = 'Y'
                            AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
			    AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));
                        print_debuginfo('4 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                        print_debuginfo('4 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );
		      ELSE
                      x_relationship_id := -1;
		      x_remit_party_id := null;
                      x_remit_supplier_site_id := null;
	              print_debuginfo('4 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('4 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );
                      END IF;
	     END;


        -- RELATIONSHIP ID IS PROVIDED
       	ELSIF ( NOT(x_relationship_id IS NULL OR x_relationship_id = -1) AND x_remit_party_id IS NULL AND x_remit_supplier_site_id IS NULL) THEN
	     BEGIN

		print_debuginfo('Relationship ID is provided');
		print_debuginfo('1 Remit-To-Supplier and Remit-To-Supplier Site are not provided');

		SELECT
		  remit_party_id,
		  remit_supplier_site_id
		INTO
		  x_remit_party_id,
		  x_remit_supplier_site_id
		FROM iby_ext_payee_relationships irel
		WHERE party_id = p_party_id
		 AND supplier_site_id = p_supplier_site_id
		 AND active = 'Y'
		 AND relationship_id = x_relationship_id
		 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
		 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

		 x_result := FND_API.G_TRUE ;

		   EXCEPTION
		    WHEN OTHERS THEN
		      print_debuginfo('1 Relationship not found');
		      x_result := FND_API.G_FALSE ;
	              print_debuginfo('1 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('1 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );

	    END;
	ELSIF ( NOT(x_relationship_id IS NULL OR x_relationship_id = -1) AND x_remit_party_id IS NULL AND NOT (x_remit_supplier_site_id IS NULL)) THEN
	     BEGIN

		print_debuginfo('Relationship ID is provided');
		print_debuginfo('2 Remit-To-Supplier is not provided');
		SELECT
		  remit_party_id
		INTO
		  x_remit_party_id
		FROM iby_ext_payee_relationships irel
		WHERE party_id = p_party_id
		 AND supplier_site_id = p_supplier_site_id
		 AND remit_supplier_site_id = x_remit_supplier_site_id
		 AND active = 'Y'
		 AND relationship_id = x_relationship_id
		 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
		 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

		 x_result := FND_API.G_TRUE ;

		   EXCEPTION
		    WHEN OTHERS THEN
		      print_debuginfo('2 Relationship not found');
		      x_result := FND_API.G_FALSE ;
	              print_debuginfo('2 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('2 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );


	    END;
	ELSIF ( NOT(x_relationship_id IS NULL OR x_relationship_id = -1) AND NOT(x_remit_party_id IS NULL) AND x_remit_supplier_site_id IS NULL) THEN
	     BEGIN

		print_debuginfo('Relationship ID is provided');
		print_debuginfo('3 Remit-To-Supplier Site is not provided');


		SELECT
		  remit_supplier_site_id
		INTO
		  x_remit_supplier_site_id
		FROM iby_ext_payee_relationships irel
		WHERE party_id = p_party_id
		 AND supplier_site_id = p_supplier_site_id
		 AND remit_party_id = x_remit_party_id
		 AND active = 'Y'
		 AND relationship_id = x_relationship_id
		 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
		 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

		 x_result := FND_API.G_TRUE ;

		   EXCEPTION
		    WHEN OTHERS THEN
		      print_debuginfo('3 Relationship not found');
		      x_result := FND_API.G_FALSE ;
	              print_debuginfo('3 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('3 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );

	    END;
	ELSIF ( NOT(x_relationship_id IS NULL OR x_relationship_id = -1) AND NOT(x_remit_party_id IS NULL) AND NOT(x_remit_supplier_site_id IS NULL) ) THEN
	     BEGIN

		print_debuginfo('Relationship ID is provided');
		print_debuginfo('4 Remit-To-Supplier and Remit-To-Supplier Site are provided');

		SELECT
		  relationship_id
		INTO
		  x_relationship_id
		FROM iby_ext_payee_relationships irel
		WHERE party_id = p_party_id
		 AND supplier_site_id = p_supplier_site_id
		 AND remit_party_id = x_remit_party_id
		 AND remit_supplier_site_id = x_remit_supplier_site_id
		 AND active = 'Y'
		 AND relationship_id = x_relationship_id
		 AND(to_char(nvl(p_date,   sysdate),   'YYYY-MM-DD HH24:MI:SS') BETWEEN(to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00')
		 AND(to_char(nvl(irel.to_date,   nvl(p_date,   sysdate)),   'YYYY-MM-DD') || ' 23:59:59'));

		 x_result := FND_API.G_TRUE ;

		   EXCEPTION
		    WHEN OTHERS THEN
		      print_debuginfo('4 Relationship not found');
		      x_result := FND_API.G_FALSE ;
	              print_debuginfo('4 Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
                      print_debuginfo('4 Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );
	     END;
        END IF;

           print_debuginfo('Output Parameters : x_result,x_relationship_id,x_remit_party_id,x_remit_supplier_site_id');
           print_debuginfo('Output Values : ' || x_result ||',' || x_relationship_id ||',' || x_remit_party_id || ','|| x_remit_supplier_site_id );
	   print_debuginfo('Exit : import_Ext_Payee_Relationship ');

	END import_Ext_Payee_Relationship;


END IBY_EXT_PAYEE_RELSHIPS_PKG;

/
