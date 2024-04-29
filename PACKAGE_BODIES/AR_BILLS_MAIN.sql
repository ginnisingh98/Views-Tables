--------------------------------------------------------
--  DDL for Package Body AR_BILLS_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BILLS_MAIN" as
 /* $Header: ARBRCOMB.pls 120.10.12010000.4 2009/11/05 00:12:07 nproddut ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

Function GTRUE RETURN VARCHAR2 IS
BEGIN
RETURN FND_API.G_TRUE;
END;


Function GFALSE RETURN VARCHAR2 IS
BEGIN
RETURN FND_API.G_FALSE;
END;

/*===========================================================================+
 | FUNCTION get_fnd_api_constants_rec                                        |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |  Forms and libraries cannot directly refer to PL/SQL package global       |
 |  variables, this function is relays FND_API constants to client side      |
 |    	                                                                     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:  None                                                    |
 |                                                                           |
 | RETURNS    : fnd_api_constants_rec                                        |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-AUG-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
FUNCTION  get_fnd_api_constants_rec RETURN fnd_api_constants_type IS

   fnd_api_constants_rec     fnd_api_constants_type;

BEGIN

  RETURN fnd_api_constants_rec;

END get_fnd_api_constants_rec;

/*===========================================================================+
 | FUNCTION get_fnd_api_constants_rec                                        |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |  Forms and libraries cannot directly refer to PL/SQL package global       |
 |  variables, this function is relays FND_MSG_PUB constants to client side  |
 |    	                                                                     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:  None                                                    |
 |                                                                           |
 | RETURNS    : fnd_api_constants_rec                                        |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-AUG-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
FUNCTION  get_fnd_msg_pub_constants_rec RETURN fnd_msg_pub_constants_type IS

   fnd_msg_pub_constants_rec fnd_msg_pub_constants_type;

BEGIN

  RETURN fnd_msg_pub_constants_rec;

END get_fnd_msg_pub_constants_rec;

-- ==========================================================================================================================
/* Function get_all_items : Function to create a PL SQL table   ( pblockitems ) of two columns


	Parameters OUT NOCOPY :

	pblockitems	PL/SQL table defined as

	Column 1 :  br_block_item 	Varchar2(5) The BlockName.FieldName appearing in the Forms module separated by a point
	Column 2 :  update_allowed      Varchar2(1) field with the values Y or N signifying if the field should be accessible
					to the user.

	Parameters IN

	pbr_module	: 	Varchar2(30) The forms module which contains fields for control.


	Call this function in the WHEN-NEW-FORM-INSTANCE trigger of the form which uses this pl sql table

*/


-- ==========================================================================================================================



function get_all_items(pbr_module IN VARCHAR2) RETURN blockitemtabtyp  IS

i INTEGER;
j INTEGER:=0;
x statetabtyp;
pblockitems blockitemtabtyp;
BEGIN

x:=load_table(pbr_module);

for i in 1..brstate.COUNT LOOP

	IF brstate(i).br_state = 'NEW'  AND brstate(i).br_module = pbr_module THEN
		j:=j+1;
     	  	pblockitems(j).br_block_item:=brstate(i).br_block_item;
	END IF;
end loop;

return pblockitems;

end get_All_items;


























-- ==========================================================================================================================
/* Function : get_all_items_status

	Returns a PL/SQL table of fields which are accessible depending on the Bills Receivable state
	Table returned is of type blockitemtabtyp



	Parameters IN :

	pbr_module 	:	varchar2(30) Module Name  NOT NULL

	Pbr_blockitem	:	PL/SQL table using the blockitemtabtyp type. NOT NULL

	Pbr_state1	:	First criteria ( State ) of the Bills Receivable.  NOT NULL

	Pbr_state2	:	Second crieria for determination of field accessibility
			 	This parameter is not mandatory. Only when a value is entered will the criteria be considered.
				If the Bills has been posted the pbr_state2 should have the value POSTED otherwise a null
 				value should be entered

	Pbr_state3	:	Third criteria for determination of field accessibility
				This parameter is not mandatory

				If the Bill has activities , the parameter pbr_state3 should have the value ACTIVITIES
				otherwise the value null should be entered.

	Call this function in the WHEN-NEW-RECORD-INSTANCE trigger of the form to refresh the items which are accessible
*/

-- ==========================================================================================================================





function get_all_items_status(pbr_module in varchar2 , pbr_blockitem in blockitemtabtyp ,  pbr_state1 in varchar2
, pbr_state2 in varchar2 , pbr_state3 in varchar2 ,  pbr_state4 in varchar2) return blockitemtabtyp IS

--
--

newstatus blockitemtabtyp;

i integer;
j integer:=0;
BEGIN



/* We need to reset all of the items back to being nonupdateble */

	newstatus:=pbr_blockitem;


	FOR i in newstatus.FIRST..newstatus.LAST LOOP
	  	newstatus(i).update_allowed:='N';
		null;
	END LOOP;



	/* Lets read the first 324 records. These are the ones in which the access is dependant upon the status of the bill */


	FOR i IN brstate.FIRST..324 LOOP

		IF   brstate(i).br_state = pbr_state1 THEN


			/* If the status matrix says N then ignore it as its already been set to N anyway */

			IF  brstate(i).update_allowed IN ('N')
				 THEN NULL;

			ELSE

			FOR j IN newstatus.FIRST..newstatus.LAST LOOP
				IF newstatus(j).br_block_item = brstate(i).br_block_item THEN
					IF newstatus(j).update_allowed in ('N' , 'Y')           THEN
						 newstatus(j).update_allowed:=brstate(i).update_allowed;
							null;
					END IF;
				END IF;
	    		END LOOP;

			END IF;

		END IF;

	END LOOP;


	/* if none of the other statuses are applicable here then leave */

	IF (pbr_state2 = 'XX' AND pbr_state3 = 'XX' AND pbr_state3 = 'XX' ) THEN

		RETURN newstatus;

	END IF;


	FOR i IN 325..brstate.LAST LOOP

                IF  ( brstate(i).br_state = pbr_state2 OR brstate(i).br_state = pbr_state3 OR brstate(i).br_state = pbr_state4 )
                THEN


			/* If the status matrix has the 'Y'  then we can ignore this */

                        IF  brstate(i).update_allowed IN ('Y') THEN NULL;

                        ELSE


			/* otherwise the value here overrides the previous one that the BR Status setup*/

                        	FOR j IN newstatus.FIRST..newstatus.LAST LOOP
                               	 	IF newstatus(j).br_block_item = brstate(i).br_block_item THEN
                                                 newstatus(j).update_allowed:='N';
                                	END IF;
                        	END LOOP;

                        END IF;

                END IF;

        END LOOP;



	RETURN newstatus;

END get_all_items_status;




-- ==========================================================================================================================
/*

Function load_table

	Returns a PL/SQL table of type StatetabType (defined in corresponding specification



	Parameters

	IN :

	Pbr_module 	: Varchar2(30)	Not Null	Name of the module which has fields for control


	This function is called by the function get_all_items





*/

-- ==========================================================================================================================

function load_table (pbr_module IN VARCHAR2 )  return statetabtyp IS

begin



IF pbr_module = 'ARBRMAIN' THEN



brstate(236).br_module:='ARBRMAIN';
brstate(236).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(236).br_state:='INCOMPLETE';
brstate(236).update_allowed:='M';

brstate(238).br_module:='ARBRMAIN';
brstate(238).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(238).br_state:='PENDING_ACCEPTANCE';
brstate(238).update_allowed:='M';

brstate(239).br_module:='ARBRMAIN';
brstate(239).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(239).br_state:='PENDING_REMITTANCE';
brstate(239).update_allowed:='N';

brstate(235).br_module:='ARBRMAIN';
brstate(235).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(235).br_state:='FACTORED';
brstate(235).update_allowed:='N';

brstate(237).br_module:='ARBRMAIN';
brstate(237).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(237).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(237).update_allowed:='N';

brstate(241).br_module:='ARBRMAIN';
brstate(241).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(241).br_state:='REMITTED';
brstate(241).update_allowed:='N';

brstate(233).br_module:='ARBRMAIN';
brstate(233).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(233).br_state:='CLOSED';
brstate(233).update_allowed:='N';

brstate(234).br_module:='ARBRMAIN';
brstate(234).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(234).br_state:='ENDORSED';
brstate(234).update_allowed:='N';

brstate(242).br_module:='ARBRMAIN';
brstate(242).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(242).br_state:='UNPAID';
brstate(242).update_allowed:='N';

brstate(240).br_module:='ARBRMAIN';
brstate(240).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(240).br_state:='PROTESTED';
brstate(240).update_allowed:='N';

brstate(232).br_module:='ARBRMAIN';
brstate(232).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate(232).br_state:='CANCELLED';
brstate(232).update_allowed:='N';

brstate(49).br_module:='ARBRMAIN';
brstate(49).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(49).br_state:='INCOMPLETE';
brstate(49).update_allowed:='N';

brstate(51).br_module:='ARBRMAIN';
brstate(51).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(51).br_state:='PENDING_ACCEPTANCE';
brstate(51).update_allowed:='N';

brstate(52).br_module:='ARBRMAIN';
brstate(52).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(52).br_state:='PENDING_REMITTANCE';
brstate(52).update_allowed:='N';

brstate(48).br_module:='ARBRMAIN';
brstate(48).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(48).br_state:='FACTORED';
brstate(48).update_allowed:='N';

brstate(50).br_module:='ARBRMAIN';
brstate(50).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(50).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(50).update_allowed:='N';

brstate(54).br_module:='ARBRMAIN';
brstate(54).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(54).br_state:='REMITTED';
brstate(54).update_allowed:='N';

brstate(46).br_module:='ARBRMAIN';
brstate(46).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(46).br_state:='CLOSED';
brstate(46).update_allowed:='N';

brstate(47).br_module:='ARBRMAIN';
brstate(47).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(47).br_state:='ENDORSED';
brstate(47).update_allowed:='N';

brstate(55).br_module:='ARBRMAIN';
brstate(55).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(55).br_state:='UNPAID';
brstate(55).update_allowed:='N';

brstate(53).br_module:='ARBRMAIN';
brstate(53).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(53).br_state:='PROTESTED';
brstate(53).update_allowed:='N';

brstate(45).br_module:='ARBRMAIN';
brstate(45).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate(45).br_state:='CANCELLED';
brstate(45).update_allowed:='N';

brstate(115).br_module:='ARBRMAIN';
brstate(115).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(115).br_state:='INCOMPLETE';
brstate(115).update_allowed:='Y';

brstate(117).br_module:='ARBRMAIN';
brstate(117).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(117).br_state:='PENDING_ACCEPTANCE';
brstate(117).update_allowed:='Y';

brstate(118).br_module:='ARBRMAIN';
brstate(118).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(118).br_state:='PENDING_REMITTANCE';
brstate(118).update_allowed:='N';

brstate(114).br_module:='ARBRMAIN';
brstate(114).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(114).br_state:='FACTORED';
brstate(114).update_allowed:='N';

brstate(116).br_module:='ARBRMAIN';
brstate(116).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(116).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(116).update_allowed:='N';

brstate(120).br_module:='ARBRMAIN';
brstate(120).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(120).br_state:='REMITTED';
brstate(120).update_allowed:='N';

brstate(112).br_module:='ARBRMAIN';
brstate(112).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(112).br_state:='CLOSED';
brstate(112).update_allowed:='N';

brstate(113).br_module:='ARBRMAIN';
brstate(113).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(113).br_state:='ENDORSED';
brstate(113).update_allowed:='N';

brstate(121).br_module:='ARBRMAIN';
brstate(121).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(121).br_state:='UNPAID';
brstate(121).update_allowed:='N';

brstate(119).br_module:='ARBRMAIN';
brstate(119).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(119).br_state:='PROTESTED';
brstate(119).update_allowed:='N';

brstate(111).br_module:='ARBRMAIN';
brstate(111).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate(111).br_state:='CANCELLED';
brstate(111).update_allowed:='N';

brstate(82).br_module:='ARBRMAIN';
brstate(82).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(82).br_state:='INCOMPLETE';
brstate(82).update_allowed:='Y';

brstate(84).br_module:='ARBRMAIN';
brstate(84).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(84).br_state:='PENDING_ACCEPTANCE';
brstate(84).update_allowed:='Y';

brstate(85).br_module:='ARBRMAIN';
brstate(85).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(85).br_state:='PENDING_REMITTANCE';
brstate(85).update_allowed:='Y';

brstate(81).br_module:='ARBRMAIN';
brstate(81).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(81).br_state:='FACTORED';
brstate(81).update_allowed:='Y';

brstate(83).br_module:='ARBRMAIN';
brstate(83).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(83).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(83).update_allowed:='Y';

brstate(87).br_module:='ARBRMAIN';
brstate(87).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(87).br_state:='REMITTED';
brstate(87).update_allowed:='Y';

brstate(79).br_module:='ARBRMAIN';
brstate(79).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(79).br_state:='CLOSED';
brstate(79).update_allowed:='Y';

brstate(80).br_module:='ARBRMAIN';
brstate(80).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(80).br_state:='ENDORSED';
brstate(80).update_allowed:='Y';

brstate(88).br_module:='ARBRMAIN';
brstate(88).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(88).br_state:='UNPAID';
brstate(88).update_allowed:='Y';

brstate(86).br_module:='ARBRMAIN';
brstate(86).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(86).br_state:='PROTESTED';
brstate(86).update_allowed:='Y';

brstate(78).br_module:='ARBRMAIN';
brstate(78).br_block_item:='RMAI_HEADER.COMMENTS';
brstate(78).br_state:='CANCELLED';
brstate(78).update_allowed:='Y';

brstate(181).br_module:='ARBRMAIN';
brstate(181).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(181).br_state:='INCOMPLETE';
brstate(181).update_allowed:='Y';

brstate(183).br_module:='ARBRMAIN';
brstate(183).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(183).br_state:='PENDING_ACCEPTANCE';
brstate(183).update_allowed:='Y';

brstate(184).br_module:='ARBRMAIN';
brstate(184).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(184).br_state:='PENDING_REMITTANCE';
brstate(184).update_allowed:='Y';

brstate(180).br_module:='ARBRMAIN';
brstate(180).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(180).br_state:='FACTORED';
brstate(180).update_allowed:='Y';

brstate(182).br_module:='ARBRMAIN';
brstate(182).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(182).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(182).update_allowed:='Y';

brstate(186).br_module:='ARBRMAIN';
brstate(186).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(186).br_state:='REMITTED';
brstate(186).update_allowed:='Y';

brstate(178).br_module:='ARBRMAIN';
brstate(178).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(178).br_state:='CLOSED';
brstate(178).update_allowed:='Y';

brstate(179).br_module:='ARBRMAIN';
brstate(179).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(179).br_state:='ENDORSED';
brstate(179).update_allowed:='Y';

brstate(187).br_module:='ARBRMAIN';
brstate(187).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(187).br_state:='UNPAID';
brstate(187).update_allowed:='Y';

brstate(185).br_module:='ARBRMAIN';
brstate(185).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(185).br_state:='PROTESTED';
brstate(185).update_allowed:='Y';

brstate(177).br_module:='ARBRMAIN';
brstate(177).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate(177).br_state:='CANCELLED';
brstate(177).update_allowed:='Y';

brstate(71).br_module:='ARBRMAIN';
brstate(71).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(71).br_state:='INCOMPLETE';
brstate(71).update_allowed:='Y';

brstate(73).br_module:='ARBRMAIN';
brstate(73).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(73).br_state:='PENDING_ACCEPTANCE';
brstate(73).update_allowed:='N';

brstate(74).br_module:='ARBRMAIN';
brstate(74).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(74).br_state:='PENDING_REMITTANCE';
brstate(74).update_allowed:='N';

brstate(70).br_module:='ARBRMAIN';
brstate(70).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(70).br_state:='FACTORED';
brstate(70).update_allowed:='N';

brstate(72).br_module:='ARBRMAIN';
brstate(72).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(72).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(72).update_allowed:='N';

brstate(76).br_module:='ARBRMAIN';
brstate(76).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(76).br_state:='REMITTED';
brstate(76).update_allowed:='N';

brstate(68).br_module:='ARBRMAIN';
brstate(68).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(68).br_state:='CLOSED';
brstate(68).update_allowed:='N';

brstate(69).br_module:='ARBRMAIN';
brstate(69).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(69).br_state:='ENDORSED';
brstate(69).update_allowed:='N';

brstate(77).br_module:='ARBRMAIN';
brstate(77).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(77).br_state:='UNPAID';
brstate(77).update_allowed:='N';

brstate(75).br_module:='ARBRMAIN';
brstate(75).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(75).br_state:='PROTESTED';
brstate(75).update_allowed:='N';

brstate(67).br_module:='ARBRMAIN';
brstate(67).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate(67).br_state:='CANCELLED';
brstate(67).update_allowed:='N';

brstate(192).br_module:='ARBRMAIN';
brstate(192).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(192).br_state:='INCOMPLETE';
brstate(192).update_allowed:='M';

brstate(194).br_module:='ARBRMAIN';
brstate(194).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(194).br_state:='PENDING_ACCEPTANCE';
brstate(194).update_allowed:='N';

brstate(195).br_module:='ARBRMAIN';
brstate(195).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(195).br_state:='PENDING_REMITTANCE';
brstate(195).update_allowed:='N';

brstate(191).br_module:='ARBRMAIN';
brstate(191).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(191).br_state:='FACTORED';
brstate(191).update_allowed:='N';

brstate(193).br_module:='ARBRMAIN';
brstate(193).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(193).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(193).update_allowed:='N';

brstate(197).br_module:='ARBRMAIN';
brstate(197).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(197).br_state:='REMITTED';
brstate(197).update_allowed:='N';

brstate(189).br_module:='ARBRMAIN';
brstate(189).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(189).br_state:='CLOSED';
brstate(189).update_allowed:='N';

brstate(190).br_module:='ARBRMAIN';
brstate(190).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(190).br_state:='ENDORSED';
brstate(190).update_allowed:='N';

brstate(198).br_module:='ARBRMAIN';
brstate(198).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(198).br_state:='UNPAID';
brstate(198).update_allowed:='N';

brstate(196).br_module:='ARBRMAIN';
brstate(196).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(196).br_state:='PROTESTED';
brstate(196).update_allowed:='N';

brstate(188).br_module:='ARBRMAIN';
brstate(188).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate(188).br_state:='CANCELLED';
brstate(188).update_allowed:='N';

brstate(203).br_module:='ARBRMAIN';
brstate(203).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(203).br_state:='INCOMPLETE';
brstate(203).update_allowed:='M';

brstate(205).br_module:='ARBRMAIN';
brstate(205).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(205).br_state:='PENDING_ACCEPTANCE';
brstate(205).update_allowed:='N';

brstate(206).br_module:='ARBRMAIN';
brstate(206).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(206).br_state:='PENDING_REMITTANCE';
brstate(206).update_allowed:='N';

brstate(202).br_module:='ARBRMAIN';
brstate(202).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(202).br_state:='FACTORED';
brstate(202).update_allowed:='N';

brstate(204).br_module:='ARBRMAIN';
brstate(204).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(204).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(204).update_allowed:='N';

brstate(208).br_module:='ARBRMAIN';
brstate(208).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(208).br_state:='REMITTED';
brstate(208).update_allowed:='N';

brstate(200).br_module:='ARBRMAIN';
brstate(200).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(200).br_state:='CLOSED';
brstate(200).update_allowed:='N';

brstate(201).br_module:='ARBRMAIN';
brstate(201).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(201).br_state:='ENDORSED';
brstate(201).update_allowed:='N';

brstate(209).br_module:='ARBRMAIN';
brstate(209).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(209).br_state:='UNPAID';
brstate(209).update_allowed:='N';

brstate(207).br_module:='ARBRMAIN';
brstate(207).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(207).br_state:='PROTESTED';
brstate(207).update_allowed:='N';

brstate(199).br_module:='ARBRMAIN';
brstate(199).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate(199).br_state:='CANCELLED';
brstate(199).update_allowed:='N';

brstate(38).br_module:='ARBRMAIN';
brstate(38).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(38).br_state:='INCOMPLETE';
brstate(38).update_allowed:='M';

brstate(40).br_module:='ARBRMAIN';
brstate(40).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(40).br_state:='PENDING_ACCEPTANCE';
brstate(40).update_allowed:='N';

brstate(41).br_module:='ARBRMAIN';
brstate(41).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(41).br_state:='PENDING_REMITTANCE';
brstate(41).update_allowed:='N';

brstate(37).br_module:='ARBRMAIN';
brstate(37).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(37).br_state:='FACTORED';
brstate(37).update_allowed:='N';

brstate(39).br_module:='ARBRMAIN';
brstate(39).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(39).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(39).update_allowed:='N';

brstate(43).br_module:='ARBRMAIN';
brstate(43).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(43).br_state:='REMITTED';
brstate(43).update_allowed:='N';

brstate(35).br_module:='ARBRMAIN';
brstate(35).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(35).br_state:='CLOSED';
brstate(35).update_allowed:='N';

brstate(36).br_module:='ARBRMAIN';
brstate(36).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(36).br_state:='ENDORSED';
brstate(36).update_allowed:='N';

brstate(44).br_module:='ARBRMAIN';
brstate(44).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(44).br_state:='UNPAID';
brstate(44).update_allowed:='N';

brstate(42).br_module:='ARBRMAIN';
brstate(42).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(42).br_state:='PROTESTED';
brstate(42).update_allowed:='N';

brstate(34).br_module:='ARBRMAIN';
brstate(34).br_block_item:='RMAI_HEADER.GL_DATE';
brstate(34).br_state:='CANCELLED';
brstate(34).update_allowed:='N';

brstate(93).br_module:='ARBRMAIN';
brstate(93).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(93).br_state:='INCOMPLETE';
brstate(93).update_allowed:='Y';

brstate(95).br_module:='ARBRMAIN';
brstate(95).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(95).br_state:='PENDING_ACCEPTANCE';
brstate(95).update_allowed:='N';

brstate(96).br_module:='ARBRMAIN';
brstate(96).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(96).br_state:='PENDING_REMITTANCE';
brstate(96).update_allowed:='N';

brstate(92).br_module:='ARBRMAIN';
brstate(92).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(92).br_state:='FACTORED';
brstate(92).update_allowed:='N';

brstate(94).br_module:='ARBRMAIN';
brstate(94).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(94).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(94).update_allowed:='N';

brstate(98).br_module:='ARBRMAIN';
brstate(98).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(98).br_state:='REMITTED';
brstate(98).update_allowed:='N';

brstate(90).br_module:='ARBRMAIN';
brstate(90).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(90).br_state:='CLOSED';
brstate(90).update_allowed:='N';

brstate(91).br_module:='ARBRMAIN';
brstate(91).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(91).br_state:='ENDORSED';
brstate(91).update_allowed:='N';

brstate(99).br_module:='ARBRMAIN';
brstate(99).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(99).br_state:='UNPAID';
brstate(99).update_allowed:='N';

brstate(97).br_module:='ARBRMAIN';
brstate(97).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(97).br_state:='PROTESTED';
brstate(97).update_allowed:='N';

brstate(89).br_module:='ARBRMAIN';
brstate(89).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate(89).br_state:='CANCELLED';
brstate(89).update_allowed:='N';

brstate(214).br_module:='ARBRMAIN';
brstate(214).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(214).br_state:='INCOMPLETE';
brstate(214).update_allowed:='Y';

brstate(216).br_module:='ARBRMAIN';
brstate(216).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(216).br_state:='PENDING_ACCEPTANCE';
brstate(216).update_allowed:='N';

brstate(217).br_module:='ARBRMAIN';
brstate(217).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(217).br_state:='PENDING_REMITTANCE';
brstate(217).update_allowed:='N';

brstate(213).br_module:='ARBRMAIN';
brstate(213).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(213).br_state:='FACTORED';
brstate(213).update_allowed:='N';

brstate(215).br_module:='ARBRMAIN';
brstate(215).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(215).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(215).update_allowed:='N';

brstate(219).br_module:='ARBRMAIN';
brstate(219).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(219).br_state:='REMITTED';
brstate(219).update_allowed:='N';

brstate(211).br_module:='ARBRMAIN';
brstate(211).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(211).br_state:='CLOSED';
brstate(211).update_allowed:='N';

brstate(212).br_module:='ARBRMAIN';
brstate(212).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(212).br_state:='ENDORSED';
brstate(212).update_allowed:='N';

brstate(220).br_module:='ARBRMAIN';
brstate(220).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(220).br_state:='UNPAID';
brstate(220).update_allowed:='N';

brstate(218).br_module:='ARBRMAIN';
brstate(218).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(218).br_state:='PROTESTED';
brstate(218).update_allowed:='N';

brstate(210).br_module:='ARBRMAIN';
brstate(210).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate(210).br_state:='CANCELLED';
brstate(210).update_allowed:='N';

brstate(225).br_module:='ARBRMAIN';
brstate(225).br_block_item:='RMAI_HEADER.LOCATION';
brstate(225).br_state:='INCOMPLETE';
brstate(225).update_allowed:='M';

brstate(227).br_module:='ARBRMAIN';
brstate(227).br_block_item:='RMAI_HEADER.LOCATION';
brstate(227).br_state:='PENDING_ACCEPTANCE';
brstate(227).update_allowed:='M';

brstate(228).br_module:='ARBRMAIN';
brstate(228).br_block_item:='RMAI_HEADER.LOCATION';
brstate(228).br_state:='PENDING_REMITTANCE';
brstate(228).update_allowed:='N';

brstate(224).br_module:='ARBRMAIN';
brstate(224).br_block_item:='RMAI_HEADER.LOCATION';
brstate(224).br_state:='FACTORED';
brstate(224).update_allowed:='N';

brstate(226).br_module:='ARBRMAIN';
brstate(226).br_block_item:='RMAI_HEADER.LOCATION';
brstate(226).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(226).update_allowed:='N';

brstate(230).br_module:='ARBRMAIN';
brstate(230).br_block_item:='RMAI_HEADER.LOCATION';
brstate(230).br_state:='REMITTED';
brstate(230).update_allowed:='N';

brstate(222).br_module:='ARBRMAIN';
brstate(222).br_block_item:='RMAI_HEADER.LOCATION';
brstate(222).br_state:='CLOSED';
brstate(222).update_allowed:='N';

brstate(223).br_module:='ARBRMAIN';
brstate(223).br_block_item:='RMAI_HEADER.LOCATION';
brstate(223).br_state:='ENDORSED';
brstate(223).update_allowed:='N';

brstate(231).br_module:='ARBRMAIN';
brstate(231).br_block_item:='RMAI_HEADER.LOCATION';
brstate(231).br_state:='UNPAID';
brstate(231).update_allowed:='N';

brstate(229).br_module:='ARBRMAIN';
brstate(229).br_block_item:='RMAI_HEADER.LOCATION';
brstate(229).br_state:='PROTESTED';
brstate(229).update_allowed:='N';

brstate(221).br_module:='ARBRMAIN';
brstate(221).br_block_item:='RMAI_HEADER.LOCATION';
brstate(221).br_state:='CANCELLED';
brstate(221).update_allowed:='N';

brstate(170).br_module:='ARBRMAIN';
brstate(170).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(170).br_state:='INCOMPLETE';
brstate(170).update_allowed:='Y';

brstate(172).br_module:='ARBRMAIN';
brstate(172).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(172).br_state:='PENDING_ACCEPTANCE';
brstate(172).update_allowed:='Y';

brstate(173).br_module:='ARBRMAIN';
brstate(173).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(173).br_state:='PENDING_REMITTANCE';
brstate(173).update_allowed:='Y';

brstate(169).br_module:='ARBRMAIN';
brstate(169).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(169).br_state:='FACTORED';
brstate(169).update_allowed:='N';

brstate(171).br_module:='ARBRMAIN';
brstate(171).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(171).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(171).update_allowed:='N';

brstate(175).br_module:='ARBRMAIN';
brstate(175).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(175).br_state:='REMITTED';
brstate(175).update_allowed:='N';

brstate(167).br_module:='ARBRMAIN';
brstate(167).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(167).br_state:='CLOSED';
brstate(167).update_allowed:='N';

brstate(168).br_module:='ARBRMAIN';
brstate(168).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(168).br_state:='ENDORSED';
brstate(168).update_allowed:='N';

brstate(176).br_module:='ARBRMAIN';
brstate(176).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(176).br_state:='UNPAID';
brstate(176).update_allowed:='Y';

brstate(174).br_module:='ARBRMAIN';
brstate(174).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(174).br_state:='PROTESTED';
brstate(174).update_allowed:='Y';

brstate(166).br_module:='ARBRMAIN';
brstate(166).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate(166).br_state:='CANCELLED';
brstate(166).update_allowed:='N';

brstate(159).br_module:='ARBRMAIN';
brstate(159).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(159).br_state:='INCOMPLETE';
brstate(159).update_allowed:='Y';

brstate(161).br_module:='ARBRMAIN';
brstate(161).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(161).br_state:='PENDING_ACCEPTANCE';
brstate(161).update_allowed:='Y';

brstate(162).br_module:='ARBRMAIN';
brstate(162).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(162).br_state:='PENDING_REMITTANCE';
brstate(162).update_allowed:='Y';

brstate(158).br_module:='ARBRMAIN';
brstate(158).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(158).br_state:='FACTORED';
brstate(158).update_allowed:='Y';

brstate(160).br_module:='ARBRMAIN';
brstate(160).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(160).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(160).update_allowed:='Y';

brstate(164).br_module:='ARBRMAIN';
brstate(164).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(164).br_state:='REMITTED';
brstate(164).update_allowed:='Y';

brstate(156).br_module:='ARBRMAIN';
brstate(156).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(156).br_state:='CLOSED';
brstate(156).update_allowed:='Y';

brstate(157).br_module:='ARBRMAIN';
brstate(157).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(157).br_state:='ENDORSED';
brstate(157).update_allowed:='Y';

brstate(165).br_module:='ARBRMAIN';
brstate(165).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(165).br_state:='UNPAID';
brstate(165).update_allowed:='Y';

brstate(163).br_module:='ARBRMAIN';
brstate(163).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(163).br_state:='PROTESTED';
brstate(163).update_allowed:='Y';

brstate(155).br_module:='ARBRMAIN';
brstate(155).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate(155).br_state:='CANCELLED';
brstate(155).update_allowed:='Y';

brstate(27).br_module:='ARBRMAIN';
brstate(27).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(27).br_state:='INCOMPLETE';
brstate(27).update_allowed:='Y';

brstate(29).br_module:='ARBRMAIN';
brstate(29).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(29).br_state:='PENDING_ACCEPTANCE';
brstate(29).update_allowed:='Y';

brstate(30).br_module:='ARBRMAIN';
brstate(30).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(30).br_state:='PENDING_REMITTANCE';
brstate(30).update_allowed:='Y';

brstate(26).br_module:='ARBRMAIN';
brstate(26).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(26).br_state:='FACTORED';
brstate(26).update_allowed:='N';

brstate(28).br_module:='ARBRMAIN';
brstate(28).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(28).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(28).update_allowed:='N';

brstate(32).br_module:='ARBRMAIN';
brstate(32).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(32).br_state:='REMITTED';
brstate(32).update_allowed:='N';

brstate(24).br_module:='ARBRMAIN';
brstate(24).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(24).br_state:='CLOSED';
brstate(24).update_allowed:='N';

brstate(25).br_module:='ARBRMAIN';
brstate(25).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(25).br_state:='ENDORSED';
brstate(25).update_allowed:='N';

brstate(33).br_module:='ARBRMAIN';
brstate(33).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(33).br_state:='UNPAID';
brstate(33).update_allowed:='Y';

brstate(31).br_module:='ARBRMAIN';
brstate(31).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(31).br_state:='PROTESTED';
brstate(31).update_allowed:='N';

brstate(23).br_module:='ARBRMAIN';
brstate(23).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate(23).br_state:='CANCELLED';
brstate(23).update_allowed:='N';

brstate(16).br_module:='ARBRMAIN';
brstate(16).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(16).br_state:='INCOMPLETE';
brstate(16).update_allowed:='Y';

brstate(18).br_module:='ARBRMAIN';
brstate(18).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(18).br_state:='PENDING_ACCEPTANCE';
brstate(18).update_allowed:='Y';

brstate(19).br_module:='ARBRMAIN';
brstate(19).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(19).br_state:='PENDING_REMITTANCE';
brstate(19).update_allowed:='Y';

brstate(15).br_module:='ARBRMAIN';
brstate(15).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(15).br_state:='FACTORED';
brstate(15).update_allowed:='N';

brstate(17).br_module:='ARBRMAIN';
brstate(17).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(17).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(17).update_allowed:='N';

brstate(21).br_module:='ARBRMAIN';
brstate(21).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(21).br_state:='REMITTED';
brstate(21).update_allowed:='N';

brstate(13).br_module:='ARBRMAIN';
brstate(13).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(13).br_state:='CLOSED';
brstate(13).update_allowed:='N';

brstate(14).br_module:='ARBRMAIN';
brstate(14).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(14).br_state:='ENDORSED';
brstate(14).update_allowed:='N';

brstate(22).br_module:='ARBRMAIN';
brstate(22).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(22).br_state:='UNPAID';
brstate(22).update_allowed:='Y';

brstate(20).br_module:='ARBRMAIN';
brstate(20).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(20).br_state:='PROTESTED';
brstate(20).update_allowed:='N';

brstate(12).br_module:='ARBRMAIN';
brstate(12).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate(12).br_state:='CANCELLED';
brstate(12).update_allowed:='N';

brstate(247).br_module:='ARBRMAIN';
brstate(247).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(247).br_state:='INCOMPLETE';
brstate(247).update_allowed:='Y';

brstate(249).br_module:='ARBRMAIN';
brstate(249).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(249).br_state:='PENDING_ACCEPTANCE';
brstate(249).update_allowed:='Y';

brstate(250).br_module:='ARBRMAIN';
brstate(250).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(250).br_state:='PENDING_REMITTANCE';
brstate(250).update_allowed:='Y';

brstate(246).br_module:='ARBRMAIN';
brstate(246).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(246).br_state:='FACTORED';
brstate(246).update_allowed:='N';

brstate(248).br_module:='ARBRMAIN';
brstate(248).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(248).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(248).update_allowed:='N';

brstate(252).br_module:='ARBRMAIN';
brstate(252).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(252).br_state:='REMITTED';
brstate(252).update_allowed:='N';

brstate(244).br_module:='ARBRMAIN';
brstate(244).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(244).br_state:='CLOSED';
brstate(244).update_allowed:='N';

brstate(245).br_module:='ARBRMAIN';
brstate(245).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(245).br_state:='ENDORSED';
brstate(245).update_allowed:='N';

brstate(253).br_module:='ARBRMAIN';
brstate(253).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(253).br_state:='UNPAID';
brstate(253).update_allowed:='Y';

brstate(251).br_module:='ARBRMAIN';
brstate(251).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(251).br_state:='PROTESTED';
brstate(251).update_allowed:='N';

brstate(243).br_module:='ARBRMAIN';
brstate(243).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate(243).br_state:='CANCELLED';
brstate(243).update_allowed:='N';

brstate(5).br_module:='ARBRMAIN';
brstate(5).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(5).br_state:='INCOMPLETE';
brstate(5).update_allowed:='Y';

brstate(7).br_module:='ARBRMAIN';
brstate(7).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(7).br_state:='PENDING_ACCEPTANCE';
brstate(7).update_allowed:='Y';

brstate(8).br_module:='ARBRMAIN';
brstate(8).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(8).br_state:='PENDING_REMITTANCE';
brstate(8).update_allowed:='Y';

brstate(4).br_module:='ARBRMAIN';
brstate(4).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(4).br_state:='FACTORED';
brstate(4).update_allowed:='N';

brstate(6).br_module:='ARBRMAIN';
brstate(6).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(6).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(6).update_allowed:='N';

brstate(10).br_module:='ARBRMAIN';
brstate(10).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(10).br_state:='REMITTED';
brstate(10).update_allowed:='N';

brstate(2).br_module:='ARBRMAIN';
brstate(2).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(2).br_state:='CLOSED';
brstate(2).update_allowed:='N';

brstate(3).br_module:='ARBRMAIN';
brstate(3).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(3).br_state:='ENDORSED';
brstate(3).update_allowed:='N';

brstate(11).br_module:='ARBRMAIN';
brstate(11).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(11).br_state:='UNPAID';
brstate(11).update_allowed:='Y';

brstate(9).br_module:='ARBRMAIN';
brstate(9).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(9).br_state:='PROTESTED';
brstate(9).update_allowed:='N';

brstate(1).br_module:='ARBRMAIN';
brstate(1).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate(1).br_state:='CANCELLED';
brstate(1).update_allowed:='N';

brstate(148).br_module:='ARBRMAIN';
brstate(148).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(148).br_state:='INCOMPLETE';
brstate(148).update_allowed:='Y';

brstate(150).br_module:='ARBRMAIN';
brstate(150).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(150).br_state:='PENDING_ACCEPTANCE';
brstate(150).update_allowed:='Y';

brstate(151).br_module:='ARBRMAIN';
brstate(151).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(151).br_state:='PENDING_REMITTANCE';
brstate(151).update_allowed:='Y';

brstate(147).br_module:='ARBRMAIN';
brstate(147).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(147).br_state:='FACTORED';
brstate(147).update_allowed:='Y';

brstate(149).br_module:='ARBRMAIN';
brstate(149).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(149).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(149).update_allowed:='Y';

brstate(153).br_module:='ARBRMAIN';
brstate(153).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(153).br_state:='REMITTED';
brstate(153).update_allowed:='N';

brstate(145).br_module:='ARBRMAIN';
brstate(145).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(145).br_state:='CLOSED';
brstate(145).update_allowed:='Y';

brstate(146).br_module:='ARBRMAIN';
brstate(146).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(146).br_state:='ENDORSED';
brstate(146).update_allowed:='Y';

brstate(154).br_module:='ARBRMAIN';
brstate(154).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(154).br_state:='UNPAID';
brstate(154).update_allowed:='Y';

brstate(152).br_module:='ARBRMAIN';
brstate(152).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(152).br_state:='PROTESTED';
brstate(152).update_allowed:='Y';

brstate(144).br_module:='ARBRMAIN';
brstate(144).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate(144).br_state:='CANCELLED';
brstate(144).update_allowed:='Y';

brstate(126).br_module:='ARBRMAIN';
brstate(126).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(126).br_state:='INCOMPLETE';
brstate(126).update_allowed:='Y';

brstate(128).br_module:='ARBRMAIN';
brstate(128).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(128).br_state:='PENDING_ACCEPTANCE';
brstate(128).update_allowed:='Y';

brstate(129).br_module:='ARBRMAIN';
brstate(129).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(129).br_state:='PENDING_REMITTANCE';
brstate(129).update_allowed:='Y';

brstate(125).br_module:='ARBRMAIN';
brstate(125).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(125).br_state:='FACTORED';
brstate(125).update_allowed:='Y';

brstate(127).br_module:='ARBRMAIN';
brstate(127).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(127).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(127).update_allowed:='N';

brstate(131).br_module:='ARBRMAIN';
brstate(131).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(131).br_state:='REMITTED';
brstate(131).update_allowed:='N';

brstate(123).br_module:='ARBRMAIN';
brstate(123).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(123).br_state:='CLOSED';
brstate(123).update_allowed:='N';

brstate(124).br_module:='ARBRMAIN';
brstate(124).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(124).br_state:='ENDORSED';
brstate(124).update_allowed:='N';

brstate(132).br_module:='ARBRMAIN';
brstate(132).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(132).br_state:='UNPAID';
brstate(132).update_allowed:='Y';

brstate(130).br_module:='ARBRMAIN';
brstate(130).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(130).br_state:='PROTESTED';
brstate(130).update_allowed:='N';

brstate(122).br_module:='ARBRMAIN';
brstate(122).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate(122).br_state:='CANCELLED';
brstate(122).update_allowed:='N';

brstate(60).br_module:='ARBRMAIN';
brstate(60).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(60).br_state:='INCOMPLETE';
brstate(60).update_allowed:='M';

brstate(62).br_module:='ARBRMAIN';
brstate(62).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(62).br_state:='PENDING_ACCEPTANCE';
brstate(62).update_allowed:='N';

brstate(63).br_module:='ARBRMAIN';
brstate(63).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(63).br_state:='PENDING_REMITTANCE';
brstate(63).update_allowed:='N';

brstate(59).br_module:='ARBRMAIN';
brstate(59).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(59).br_state:='FACTORED';
brstate(59).update_allowed:='N';

brstate(61).br_module:='ARBRMAIN';
brstate(61).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(61).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(61).update_allowed:='N';

brstate(65).br_module:='ARBRMAIN';
brstate(65).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(65).br_state:='REMITTED';
brstate(65).update_allowed:='N';

brstate(57).br_module:='ARBRMAIN';
brstate(57).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(57).br_state:='CLOSED';
brstate(57).update_allowed:='N';

brstate(58).br_module:='ARBRMAIN';
brstate(58).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(58).br_state:='ENDORSED';
brstate(58).update_allowed:='N';

brstate(66).br_module:='ARBRMAIN';
brstate(66).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(66).br_state:='UNPAID';
brstate(66).update_allowed:='N';

brstate(64).br_module:='ARBRMAIN';
brstate(64).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(64).br_state:='PROTESTED';
brstate(64).update_allowed:='N';

brstate(56).br_module:='ARBRMAIN';
brstate(56).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate(56).br_state:='CANCELLED';
brstate(56).update_allowed:='N';

brstate(104).br_module:='ARBRMAIN';
brstate(104).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(104).br_state:='INCOMPLETE';
brstate(104).update_allowed:='M';

brstate(106).br_module:='ARBRMAIN';
brstate(106).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(106).br_state:='PENDING_ACCEPTANCE';
brstate(106).update_allowed:='N';

brstate(107).br_module:='ARBRMAIN';
brstate(107).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(107).br_state:='PENDING_REMITTANCE';
brstate(107).update_allowed:='N';

brstate(103).br_module:='ARBRMAIN';
brstate(103).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(103).br_state:='FACTORED';
brstate(103).update_allowed:='N';

brstate(105).br_module:='ARBRMAIN';
brstate(105).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(105).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(105).update_allowed:='N';

brstate(109).br_module:='ARBRMAIN';
brstate(109).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(109).br_state:='REMITTED';
brstate(109).update_allowed:='N';

brstate(101).br_module:='ARBRMAIN';
brstate(101).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(101).br_state:='CLOSED';
brstate(101).update_allowed:='N';

brstate(102).br_module:='ARBRMAIN';
brstate(102).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(102).br_state:='ENDORSED';
brstate(102).update_allowed:='N';

brstate(110).br_module:='ARBRMAIN';
brstate(110).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(110).br_state:='UNPAID';
brstate(110).update_allowed:='N';

brstate(108).br_module:='ARBRMAIN';
brstate(108).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(108).br_state:='PROTESTED';
brstate(108).update_allowed:='N';

brstate(100).br_module:='ARBRMAIN';
brstate(100).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate(100).br_state:='CANCELLED';
brstate(100).update_allowed:='N';

brstate(137).br_module:='ARBRMAIN';
brstate(137).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(137).br_state:='INCOMPLETE';
brstate(137).update_allowed:='M';

brstate(139).br_module:='ARBRMAIN';
brstate(139).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(139).br_state:='PENDING_ACCEPTANCE';
brstate(139).update_allowed:='N';

brstate(140).br_module:='ARBRMAIN';
brstate(140).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(140).br_state:='PENDING_REMITTANCE';
brstate(140).update_allowed:='N';

brstate(136).br_module:='ARBRMAIN';
brstate(136).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(136).br_state:='FACTORED';
brstate(136).update_allowed:='N';

brstate(138).br_module:='ARBRMAIN';
brstate(138).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(138).br_state:='MATURED_PEND_RISK_ELIMINATION';
brstate(138).update_allowed:='N';

brstate(142).br_module:='ARBRMAIN';
brstate(142).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(142).br_state:='REMITTED';
brstate(142).update_allowed:='N';

brstate(134).br_module:='ARBRMAIN';
brstate(134).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(134).br_state:='CLOSED';
brstate(134).update_allowed:='N';

brstate(135).br_module:='ARBRMAIN';
brstate(135).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(135).br_state:='ENDORSED';
brstate(135).update_allowed:='N';

brstate(143).br_module:='ARBRMAIN';
brstate(143).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(143).br_state:='UNPAID';
brstate(143).update_allowed:='N';

brstate(141).br_module:='ARBRMAIN';
brstate(141).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(141).br_state:='PROTESTED';
brstate(141).update_allowed:='N';

brstate(133).br_module:='ARBRMAIN';
brstate(133).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate(133).br_state:='CANCELLED';
brstate(133).update_allowed:='N';


brstate( 254).br_module:='ARBRMAIN';
brstate( 254).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate( 254).br_state:='NEW';
brstate( 254).update_allowed:='Y';

brstate( 255).br_module:='ARBRMAIN';
brstate( 255).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate( 255).br_state:='NEW';
brstate( 255).update_allowed:='Y';

brstate( 256).br_module:='ARBRMAIN';
brstate( 256).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate( 256).br_state:='NEW';
brstate( 256).update_allowed:='Y';

brstate( 257).br_module:='ARBRMAIN';
brstate( 257).br_block_item:='RMAI_HEADER.GL_DATE';
brstate( 257).br_state:='NEW';
brstate( 257).update_allowed:='M';

brstate( 258).br_module:='ARBRMAIN';
brstate( 258).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate( 258).br_state:='NEW';
brstate( 258).update_allowed:='M';

brstate( 259).br_module:='ARBRMAIN';
brstate( 259).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate( 259).br_state:='NEW';
brstate( 259).update_allowed:='M';

brstate( 260).br_module:='ARBRMAIN';
brstate( 260).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate( 260).br_state:='NEW';
brstate( 260).update_allowed:='Y';

brstate( 261).br_module:='ARBRMAIN';
brstate( 261).br_block_item:='RMAI_HEADER.COMMENTS';
brstate( 261).br_state:='NEW';
brstate( 261).update_allowed:='Y';

brstate( 262).br_module:='ARBRMAIN';
brstate( 262).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate( 262).br_state:='NEW';
brstate( 262).update_allowed:='M';

brstate( 263).br_module:='ARBRMAIN';
brstate( 263).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate( 263).br_state:='NEW';
brstate( 263).update_allowed:='M';

brstate( 264).br_module:='ARBRMAIN';
brstate( 264).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate( 264).br_state:='NEW';
brstate( 264).update_allowed:='Y';

brstate( 265).br_module:='ARBRMAIN';
brstate( 265).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate( 265).br_state:='NEW';
brstate( 265).update_allowed:='Y';

brstate( 266).br_module:='ARBRMAIN';
brstate( 266).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate( 266).br_state:='NEW';
brstate( 266).update_allowed:='M';

brstate( 267).br_module:='ARBRMAIN';
brstate( 267).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate( 267).br_state:='NEW';
brstate( 267).update_allowed:='Y';

brstate( 268).br_module:='ARBRMAIN';
brstate( 268).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate( 268).br_state:='NEW';
brstate( 268).update_allowed:='Y';

brstate( 269).br_module:='ARBRMAIN';
brstate( 269).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate( 269).br_state:='NEW';
brstate( 269).update_allowed:='Y';

brstate( 270).br_module:='ARBRMAIN';
brstate( 270).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate( 270).br_state:='NEW';
brstate( 270).update_allowed:='Y';

brstate( 271).br_module:='ARBRMAIN';
brstate( 271).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate( 271).br_state:='NEW';
brstate( 271).update_allowed:='M';

brstate( 272).br_module:='ARBRMAIN';
brstate( 272).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate( 272).br_state:='NEW';
brstate( 272).update_allowed:='M';

brstate( 273).br_module:='ARBRMAIN';
brstate( 273).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate( 273).br_state:='NEW';
brstate( 273).update_allowed:='Y';

brstate( 274).br_module:='ARBRMAIN';
brstate( 274).br_block_item:='RMAI_HEADER.LOCATION';
brstate( 274).br_state:='NEW';
brstate( 274).update_allowed:='M';

brstate( 275).br_module:='ARBRMAIN';
brstate( 275).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate( 275).br_state:='NEW';
brstate( 275).update_allowed:='M';

brstate( 276).br_module:='ARBRMAIN';
brstate( 276).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate( 276).br_state:='NEW';
brstate( 276).update_allowed:='Y';



/* Here are the status which override */

brstate( 277).br_module:='ARBRMAIN';
brstate( 277).br_block_item:='RMAI_HEADER.GL_DATE';
brstate( 277).br_state:='POSTED';
brstate( 277).update_allowed:='N';

brstate( 278).br_module:='ARBRMAIN';
brstate( 278).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate( 278).br_state:='POSTED';
brstate( 278).update_allowed:='N';

brstate( 279).br_module:='ARBRMAIN';
brstate( 279).br_block_item:='RMAI_HEADER.COMMENTS';
brstate( 279).br_state:='POSTED';
brstate( 279).update_allowed:='Y';

brstate( 280).br_module:='ARBRMAIN';
brstate( 280).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate( 280).br_state:='POSTED';
brstate( 280).update_allowed:='N';

brstate( 281).br_module:='ARBRMAIN';
brstate( 281).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate( 281).br_state:='POSTED';
brstate( 281).update_allowed:='N';

brstate( 282).br_module:='ARBRMAIN';
brstate( 282).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate( 282).br_state:='POSTED';
brstate( 282).update_allowed:='N';

brstate( 283).br_module:='ARBRMAIN';
brstate( 283).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate( 283).br_state:='POSTED';
brstate( 283).update_allowed:='Y';

brstate( 284).br_module:='ARBRMAIN';
brstate( 284).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate( 284).br_state:='POSTED';
brstate( 284).update_allowed:='N';

brstate( 285).br_module:='ARBRMAIN';
brstate( 285).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate( 285).br_state:='POSTED';
brstate( 285).update_allowed:='Y';

brstate( 286).br_module:='ARBRMAIN';
brstate( 286).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate( 286).br_state:='POSTED';
brstate( 286).update_allowed:='N';

brstate( 287).br_module:='ARBRMAIN';
brstate( 287).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate( 287).br_state:='POSTED';
brstate( 287).update_allowed:='Y';

brstate( 288).br_module:='ARBRMAIN';
brstate( 288).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate( 288).br_state:='POSTED';
brstate( 288).update_allowed:='Y';

brstate( 289).br_module:='ARBRMAIN';
brstate( 289).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate( 289).br_state:='POSTED';
brstate( 289).update_allowed:='N';

brstate( 290).br_module:='ARBRMAIN';
brstate( 290).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate( 290).br_state:='POSTED';
brstate( 290).update_allowed:='N';

brstate( 291).br_module:='ARBRMAIN';
brstate( 291).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate( 291).br_state:='POSTED';
brstate( 291).update_allowed:='N';

brstate( 292).br_module:='ARBRMAIN';
brstate( 292).br_block_item:='RMAI_HEADER.LOCATION';
brstate( 292).br_state:='POSTED';
brstate( 292).update_allowed:='N';

brstate( 293).br_module:='ARBRMAIN';
brstate( 293).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate( 293).br_state:='POSTED';
brstate( 293).update_allowed:='N';

brstate( 294).br_module:='ARBRMAIN';
brstate( 294).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate( 294).br_state:='POSTED';
brstate( 294).update_allowed:='Y';

brstate( 295).br_module:='ARBRMAIN';
brstate( 295).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate( 295).br_state:='POSTED';
brstate( 295).update_allowed:='Y';

brstate( 296).br_module:='ARBRMAIN';
brstate( 296).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate( 296).br_state:='POSTED';
brstate( 296).update_allowed:='Y';

brstate( 297).br_module:='ARBRMAIN';
brstate( 297).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate( 297).br_state:='POSTED';
brstate( 297).update_allowed:='Y';

brstate( 298).br_module:='ARBRMAIN';
brstate( 298).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate( 298).br_state:='POSTED';
brstate( 298).update_allowed:='N';

brstate( 299).br_module:='ARBRMAIN';
brstate( 299).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate( 299).br_state:='POSTED';
brstate( 299).update_allowed:='N';


brstate( 300).br_module:='ARBRMAIN';
brstate( 300).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate( 300).br_state:='ACTIVITIES';
brstate( 300).update_allowed:='Y';

brstate( 301).br_module:='ARBRMAIN';
brstate( 301).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate( 301).br_state:='ACTIVITIES';
brstate( 301).update_allowed:='Y';

brstate( 302).br_module:='ARBRMAIN';
brstate( 302).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate( 302).br_state:='ACTIVITIES';
brstate( 302).update_allowed:='Y';

brstate( 303).br_module:='ARBRMAIN';
brstate( 303).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate( 303).br_state:='ACTIVITIES';
brstate( 303).update_allowed:='Y';

brstate( 304).br_module:='ARBRMAIN';
brstate( 304).br_block_item:='RMAI_HEADER.GL_DATE';
brstate( 304).br_state:='ACTIVITIES';
brstate( 304).update_allowed:='N';

brstate( 305).br_module:='ARBRMAIN';
brstate( 305).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate( 305).br_state:='ACTIVITIES';
brstate( 305).update_allowed:='N';

brstate( 306).br_module:='ARBRMAIN';
brstate( 306).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate( 306).br_state:='ACTIVITIES';
brstate( 306).update_allowed:='N';

brstate( 307).br_module:='ARBRMAIN';
brstate( 307).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate( 307).br_state:='ACTIVITIES';
brstate( 307).update_allowed:='N';

brstate( 308).br_module:='ARBRMAIN';
brstate( 308).br_block_item:='RMAI_HEADER.COMMENTS';
brstate( 308).br_state:='ACTIVITIES';
brstate( 308).update_allowed:='Y';

brstate( 309).br_module:='ARBRMAIN';
brstate( 309).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate( 309).br_state:='ACTIVITIES';
brstate( 309).update_allowed:='N';

brstate( 310).br_module:='ARBRMAIN';
brstate( 310).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate( 310).br_state:='ACTIVITIES';
brstate( 310).update_allowed:='N';

brstate( 311).br_module:='ARBRMAIN';
brstate( 311).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate( 311).br_state:='ACTIVITIES';
brstate( 311).update_allowed:='N';

brstate( 312).br_module:='ARBRMAIN';
brstate( 312).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate( 312).br_state:='ACTIVITIES';
brstate( 312).update_allowed:='Y';

brstate( 313).br_module:='ARBRMAIN';
brstate( 313).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate( 313).br_state:='ACTIVITIES';
brstate( 313).update_allowed:='N';

brstate( 314).br_module:='ARBRMAIN';
brstate( 314).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate( 314).br_state:='ACTIVITIES';
brstate( 314).update_allowed:='Y';

brstate( 315).br_module:='ARBRMAIN';
brstate( 315).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate( 315).br_state:='ACTIVITIES';
brstate( 315).update_allowed:='N';

brstate( 316).br_module:='ARBRMAIN';
brstate( 316).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate( 316).br_state:='ACTIVITIES';
brstate( 316).update_allowed:='Y';

brstate( 317).br_module:='ARBRMAIN';
brstate( 317).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate( 317).br_state:='ACTIVITIES';
brstate( 317).update_allowed:='Y';

brstate( 318).br_module:='ARBRMAIN';
brstate( 318).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate( 318).br_state:='ACTIVITIES';
brstate( 318).update_allowed:='N';

brstate( 319).br_module:='ARBRMAIN';
brstate( 319).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate( 319).br_state:='ACTIVITIES';
brstate( 319).update_allowed:='N';

brstate( 320).br_module:='ARBRMAIN';
brstate( 320).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate( 320).br_state:='ACTIVITIES';
brstate( 320).update_allowed:='N';

brstate( 321).br_module:='ARBRMAIN';
brstate( 321).br_block_item:='RMAI_HEADER.LOCATION';
brstate( 321).br_state:='ACTIVITIES';
brstate( 321).update_allowed:='N';

brstate( 322).br_module:='ARBRMAIN';
brstate( 322).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate( 322).br_state:='ACTIVITIES';
brstate( 322).update_allowed:='N';

brstate( 323).br_module:='ARBRMAIN';
brstate( 323).br_block_item:='RMAI_HEADER.REMIT_BANK_NAME';
brstate( 323).br_state:='SELECTED';
brstate( 323).update_allowed:='N';

brstate( 324).br_module:='ARBRMAIN';
brstate( 324).br_block_item:='RMAI_HEADER.REMIT_BRANCH_NAME';
brstate( 324).br_state:='SELECTED';
brstate( 324).update_allowed:='N';

brstate( 325).br_module:='ARBRMAIN';
brstate( 325).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NUM';
brstate( 325).br_state:='SELECTED';
brstate( 325).update_allowed:='N';

brstate( 326).br_module:='ARBRMAIN';
brstate( 326).br_block_item:='RMAI_HEADER.REMIT_ACCOUNT_NAME';
brstate( 326).br_state:='SELECTED';
brstate( 326).update_allowed:='N';

brstate( 327).br_module:='ARBRMAIN';
brstate( 327).br_block_item:='RMAI_HEADER.GL_DATE';
brstate( 327).br_state:='SELECTED';
brstate( 327).update_allowed:='N';

brstate( 328).br_module:='ARBRMAIN';
brstate( 328).br_block_item:='RMAI_HEADER.BATCH_SOURCE_NAME';
brstate( 328).br_state:='SELECTED';
brstate( 328).update_allowed:='N';

brstate( 329).br_module:='ARBRMAIN';
brstate( 329).br_block_item:='RMAI_HEADER.TRANS_TYPE';
brstate( 329).br_state:='SELECTED';
brstate( 329).update_allowed:='N';

brstate( 330).br_module:='ARBRMAIN';
brstate( 330).br_block_item:='RMAI_HEADER.DOC_SEQUENCE_VALUE';
brstate( 330).br_state:='SELECTED';
brstate( 330).update_allowed:='N';

brstate( 331).br_module:='ARBRMAIN';
brstate( 331).br_block_item:='RMAI_HEADER.COMMENTS';
brstate( 331).br_state:='SELECTED';
brstate( 331).update_allowed:='Y';

brstate( 332).br_module:='ARBRMAIN';
brstate( 332).br_block_item:='RMAI_HEADER.INVOICE_CURRENCY_CODE';
brstate( 332).br_state:='SELECTED';
brstate( 332).update_allowed:='N';

brstate( 333).br_module:='ARBRMAIN';
brstate( 333).br_block_item:='RMAI_HEADER.TRX_DATE';
brstate( 333).br_state:='SELECTED';
brstate( 333).update_allowed:='N';

brstate( 334).br_module:='ARBRMAIN';
brstate( 334).br_block_item:='RMAI_HEADER.BR_AMOUNT';
brstate( 334).br_state:='SELECTED';
brstate( 334).update_allowed:='N';

brstate( 335).br_module:='ARBRMAIN';
brstate( 335).br_block_item:='RMAI_HEADER.TERM_DUE_DATE';
brstate( 335).br_state:='SELECTED';
brstate( 335).update_allowed:='N';

brstate( 336).br_module:='ARBRMAIN';
brstate( 336).br_block_item:='RMAI_HEADER.TRX_NUMBER';
brstate( 336).br_state:='SELECTED';
brstate( 336).update_allowed:='N';

brstate( 337).br_module:='ARBRMAIN';
brstate( 337).br_block_item:='RMAI_HEADER.SPECIAL_INSTRUCTIONS';
brstate( 337).br_state:='SELECTED';
brstate( 337).update_allowed:='Y';

brstate( 338).br_module:='ARBRMAIN';
brstate( 338).br_block_item:='RMAI_HEADER.PRINTING_OPTION';
brstate( 338).br_state:='SELECTED';
brstate( 338).update_allowed:='N';

brstate( 339).br_module:='ARBRMAIN';
brstate( 339).br_block_item:='RMAI_HEADER.OVERRIDE_REMIT_ACCOUNT_FLAG';
brstate( 339).br_state:='SELECTED';
brstate( 339).update_allowed:='N';

brstate( 340).br_module:='ARBRMAIN';
brstate( 340).br_block_item:='RMAI_HEADER.CONTACT_NAME';
brstate( 340).br_state:='SELECTED';
brstate( 340).update_allowed:='Y';

brstate( 341).br_module:='ARBRMAIN';
brstate( 341).br_block_item:='RMAI_HEADER.DRAWEE_NAME';
brstate( 341).br_state:='SELECTED';
brstate( 341).update_allowed:='N';

brstate( 342).br_module:='ARBRMAIN';
brstate( 342).br_block_item:='RMAI_HEADER.DRAWEE_NUMBER';
brstate( 342).br_state:='SELECTED';
brstate( 342).update_allowed:='N';

brstate( 343).br_module:='ARBRMAIN';
brstate( 343).br_block_item:='RMAI_HEADER.JGZZ_FISCAL_CODE';
brstate( 343).br_state:='SELECTED';
brstate( 343).update_allowed:='N';

brstate( 344).br_module:='ARBRMAIN';
brstate( 344).br_block_item:='RMAI_HEADER.LOCATION';
brstate( 344).br_state:='SELECTED';
brstate( 344).update_allowed:='N';

brstate( 345).br_module:='ARBRMAIN';
brstate( 345).br_block_item:='RMAI_HEADER.ADDRESS1';
brstate( 345).br_state:='SELECTED';
brstate( 345).update_allowed:='N';


END IF;





-- br_common_status.create_currentform_table(pbr_module);

return brstate;

end load_table;




FUNCTION br_seq_enterable(p_sob_id in number , p_trans_type in varchar2 , P_trx_date in date ) RETURN boolean IS



fndseqnum number:=0;
docseq_id  number;
docseq_type fnd_document_sequences.type%TYPE;
docseq_name varchar2(30);
seq_ass_id number;
prd_tab_name varchar2(30);
aud_tab_name varchar2(30);
msg_flag varchar2(30);
db_seq_name varchar2(30);
suppress_error varchar2(1);
suppress_warn varchar2(1);

begin

	IF P_trans_type IS NULL THEN

			RETURN FALSE;

	END IF;


FNDSEQNUM:=FND_SEQNUM.GET_SEQ_INFO(app_id=>222 ,
                                cat_code=>p_trans_type ,
                                sob_id=>p_sob_id ,
				met_code=>'M' ,
                                trx_date=>NVL(p_trx_date , TRUNC(sysdate))  ,
                                docseq_id=>docseq_id ,
                                docseq_type=>docseq_type,
				docseq_name=>docseq_name ,
                                db_seq_name=>db_seq_name ,
				seq_ass_id=>seq_ass_id ,
                                prd_tab_name=>prd_tab_name ,
				aud_tab_name=>aud_tab_name ,
				msg_flag=>msg_flag,
                                suppress_error=>'Y' ,
				suppress_warn=>'Y');

/* If we have sequence success SEQSUCC and if the document sequence type is manual then a sequence number should
  be entered by the user otherwise the user should not be allowed to enter the field */

                                        IF fndseqnum = fnd_seqnum.seqsucc THEN

						IF docseq_type in ('A' , 'G' ) THEN
							RETURN FALSE;
                               			 ELSIF docseq_type in ('M') THEN
							RETURN TRUE;
						ELSE
							RETURN FALSE;
						END IF;
					ELSE

                                        RETURN  FALSE;

					END IF;

end br_seq_enterable;

--
--  Returns  POSTED if the bill has been posted to GL
--

FUNCTION br_posted (p_customer_trx_id in NUMBER) RETURN VARCHAR2 IS

customer_trx_id ra_customer_trx.customer_trx_id%TYPE;


Cursor Cposted (CustomerTrxId NUMBER) IS SELECT
customer_trx_id
from ar_transaction_history
where customer_trx_id = CUSTOMERTRXID
and posting_control_id <> -3
and gl_posted_date IS NOT NULL;

begin

	open Cposted(p_customer_trx_id);

	fetch Cposted into Customer_trx_id;

	if Cposted%FOUND THEN
		close Cposted;
		return 'POSTED';
	ELSE
		close Cposted;
		return 'XX';
	END IF;

END br_posted;

FUNCTION br_selected(p_customer_trx_id in number) return VARCHAR2 IS

cursor Cselremit(CustomerTrxId NUMBER)
IS SELECT
customer_trx_id
FROM
ar_batches b ,
ar_payment_schedules p
where p.customer_trx_id = CUSTOMERTRXID
and p.reserved_type = 'REMITTANCE'
and p.reserved_value=b.batch_id
and b.status='OP';


dummy number;

BEGIN

open Cselremit(p_customer_trx_id);

fetch Cselremit into dummy;

IF Cselremit%FOUND THEN
		CLOSE CselREMIT;
		RETURN 'SELECTED';
	ELSE

	 CLOSE CselREMIT;
	RETURN 'XX';

END IF;

END br_selected;

FUNCTION fetch_assignments(
  Customer_trx_id 	 IN NUMBER,
  Drawee_id 		 IN NUMBER,
  Pay_unrelated_invoices IN VARCHAR2,
  pg_where_clause 	 IN VARCHAR2,
  pg_order_clause 	 IN VARCHAR2,
  p_le_id                IN NUMBER,
  AssignMentAmount 	 IN NUMBER,
  AssignTab 		 IN OUT NOCOPY AssignTabTyp,
  Extended_total 	 OUT NOCOPY NUMBER)
RETURN BOOLEAN IS

TYPE AssignCurTyp IS REF CURSOR;
AssignCur 	AssignCurTyp;
TempAssignRec 	AssignRecTyp;
TotalSoFar 	NUMBER;
AssignCurStr 	VARCHAR2(8000);
J 		INTEGER:=0;
NewTotal 	NUMBER;
br_currency	VARCHAR2(15);
br_trxdate	VARCHAR2(30);
br_trxid	NUMBER;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('fetch_assignments()+');
      arp_util.debug(  'Dump out NOCOPY the parameters :');
      arp_util.debug(  'Customer_trx_id :'||Customer_trx_id);
      arp_util.debug(  'Drawee_id :'||Drawee_id);
      arp_util.debug(  'Pay_unrelated_invoices :'||Pay_unrelated_invoices);
      arp_util.debug(  'pg_where_clause :'|| pg_where_clause );
      arp_util.debug(  'p_le_id:'|| p_le_id);
      arp_util.debug(  'pg_order_clause :' || pg_order_clause );
      arp_util.debug(  'AssignmentAmount :'|| AssignMentAmount );
   END IF;

   /* LE - R12 : add trx.legal_entity_id as a condition */
   /* modified for tca update */
   /* bug 1637367 Removed ; introduced in 115.11 (modifications for TCA update) */
   /* #1 retrieve the existing assignments to this BR */

AssignCurStr:=
'Select
 TRX.trx_number,
 TRX.doc_sequence_value,
 TRX.trx_date,
 TRX.comments,
 TRX.purchase_order,
 TRX.invoice_currency_code,
 LINES.customer_trx_id,
 NULL,
 PAYS.amount_due_original,
 PAYS.amount_due_remaining,
 PAYS.acctd_amount_due_remaining,
 PAYS.due_date,
 PAYS.exchange_rate,
 PAYS.terms_sequence_number,
 PARTY.jgzz_fiscal_code,
 CUST_ACCT.account_number,
 substrb(party.party_name,1,50),
 CUST_ACCT.customer_class_code,
 PARTY.category_code,
 ARPT_SQL_FUNC_UTIL.get_lookup_meaning(''CUSTOMER_CATEGORY'', party.category_code),
 ARPT_SQL_FUNC_UTIL.get_trx_type_details(TRX.cust_trx_type_id,''NAME''),
 ARPT_SQL_FUNC_UTIL.get_lookup_meaning(''INV/CM'', types.type),
 ARPT_SQL_FUNC_UTIL.get_trx_type_details(TRX.cust_trx_type_id,''TYPE''),
 METH.name,
 METH.receipt_method_id,
 SITE.location,
 TRX.bill_to_site_use_id,
 ABB.bank_name,
 ABB.branch_party_id bank_branch_id,
 ABA.bank_account_id,
 CONS.cons_billing_number,
 CONS.cons_inv_id,
 LINES.br_ref_customer_trx_id,
 LINES.br_ref_payment_schedule_id,
 LINES.extended_amount,
 LINES.extended_acctd_amount,
 LINES.customer_trx_line_id
 FROM
 RA_CUSTOMER_TRX         TRX ,
 RA_CUST_TRX_TYPES 	 TYPES,
 AR_PAYMENT_SCHEDULES    PAYS ,
 HZ_CUST_ACCOUNTS        CUST_ACCT ,
 HZ_PARTIES		 PARTY,
 AR_RECEIPT_METHODS      METH,
 CE_BANK_BRANCHES_V      ABB,
 HZ_CUST_SITE_USES       SITE,
 AP_BANK_ACCOUNTS        ABA,
 RA_CUSTOMER_TRX_LINES 	 LINES ,
 AR_CONS_INV_ALL	 CONS
 WHERE trx.legal_entity_id = ' || p_le_id ||
 ' and trx.bill_to_customer_id = cust_acct.cust_account_id
 and trx.cust_trx_type_id = types.cust_trx_type_id
 and cust_acct.party_id = party.party_id
 and trx.customer_trx_id = pays.customer_trx_id
 and pays.payment_schedule_id = lines.br_ref_payment_schedule_id
 and site.site_use_id = trx.bill_to_site_use_id
 and trx.customer_bank_account_id = aba.bank_account_id (+)
 and aba.bank_branch_id = abb.branch_party_id (+)
 and cons.cons_inv_id(+) = pays.cons_inv_id
 and trx.receipt_method_id = meth.receipt_method_id (+)
 and lines.customer_trx_id = '|| Customer_trx_id;

   TotalSoFar := 0;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'Inserting the existing assignments into the table ');
   END IF;

   OPEN  AssignCur FOR AssignCurStr;
   LOOP
      FETCH AssignCur INTO  TempAssignRec;
      EXIT WHEN AssignCur%NOTFOUND;

      Assigntab(AssignCur%ROWCOUNT) := TempAssignRec;

      TotalSoFar := TotalSoFar+NVL(TempAssignRec.Extended_amount , 0);

      /* increment record count */
      j := j + 1;
   END LOOP;
   CLOSE AssignCur;

   /* bug 2201843 :
      1) eliminate join to RA_CUSTOMER_TRX billsrec by storing BR's currency and
         trxdate of the BR in local variables br_currency and br_trxdate
      2) replace TRX.drawee_id = cust_acct.cust_account_id OR
                 TRX.bill_to_customer_id = cust_acct.cust_account_id
         with decode to avoid full scan on HZ_CUST_ACCOUNTS
      3) use arpt_sql_func_util to eliminate join to ar_lookups

      bug 1853587 :
      In not exists clause below, we are excluding all transactions that have
      already been assigned to a BR.
      An open transaction can be exchanged for a BR if :
       - it has not yet been assigned to this BR
         (this prevents one trx from being assigned to the same BR twice) OR
       - if it is assigned to another BR but it still has an outstanding amount
   */

   br_trxid := customer_trx_id;

  --Ajay bye passed the GSCC check.
   select '''' || invoice_currency_code ||'''',
          'to_dat'||'e(''' ||trx_date||''')'
     into br_currency,
          br_trxdate
     from ra_customer_trx
    where customer_trx_id = br_trxid;

   /* get all non-BR transactions that can be assigned to this BR */

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'Inserting the new assignments ');
   END IF;

   /* bug 2473700 : for quick assign, show current balance due for invoices */
   /* modified for tca update */
   /* bug7046838 : Modified the query for performance improvement. */
AssignCurStr:=
'Select
 TRX.trx_number,
 TRX.doc_sequence_value,
 TRX.trx_date,
 TRX.comments,
 TRX.purchase_order,
 TRX.invoice_currency_code,
 NULL,
 NULL,
 PAYS.amount_due_original,
 -- bug 2473700 NULL,
 PAYS.amount_due_remaining,
 NULL,
 PAYS.due_date,
 PAYS.exchange_rate,
 PAYS.terms_sequence_number,
 PARTY.jgzz_fiscal_code,
 CUST_ACCT.account_number,
 substrb(PARTY.PARTY_name,1,50),
 CUST_ACCT.customer_class_code,
 PARTY.category_code,
 ARPT_SQL_FUNC_UTIL.get_lookup_meaning(''CUSTOMER_CATEGORY'', party.category_code),
 ARPT_SQL_FUNC_UTIL.get_trx_type_details(TRX.cust_trx_type_id,''NAME''),
 ARPT_SQL_FUNC_UTIL.get_lookup_meaning(''INV/CM'', types.type),
 ARPT_SQL_FUNC_UTIL.get_trx_type_details(TRX.cust_trx_type_id,''TYPE''),
 METH.name,
 METH.receipt_method_id,
 SITE.location,
 TRX.bill_to_site_use_id,
 ABB.bank_name,
 ABB.branch_party_id bank_branch_id,
 ABA.bank_account_id,
 NULL,
 NULL,
 TRX.customer_trx_id,             /* br_ref_customer_trx_id */
 PAYS.payment_schedule_id,        /* br_ref_payment_schedule_id */
 PAYS.amount_due_remaining,       /* Extended Amount */
 PAYS.acctd_amount_due_remaining, /* Extended Acctd Amount */
 NULL				  /* Customer_trx_line_id */
 FROM
 RA_CUST_TRX_TYPES	 TYPES,
 RA_CUSTOMER_TRX         TRX ,
 AR_PAYMENT_SCHEDULES    PAYS ,
 HZ_CUST_ACCOUNTS        CUST_ACCT ,
 HZ_PARTIES		 PARTY,
 AR_receipt_METHODS      METH,
 CE_BANK_BRANCHES_V      ABB,
 HZ_CUST_SITE_USES       SITE,
 ap_bank_accounts        ABA
 where trx.legal_entity_id = ' || p_le_id ||
' and decode(pays.class,''BR'', TRX.drawee_id, TRX.bill_to_customer_id) = cust_acct.cust_account_id
 and CUST_ACCT.party_id = PARTY.party_id
 and TRX.customer_trx_id = PAYS.customer_trx_id
 and TRX.cust_trx_type_id = TYPES.cust_trx_type_id
 and PAYS.reserved_type IS NULL
 and PAYS.amount_due_remaining <> 0
 and SITE.SITE_USE_ID = TRX.BILL_TO_SITE_USE_ID
 and TRX.CUSTOMER_BANK_ACCOUNT_ID = ABA.BANK_ACCOUNT_ID (+)
 and ABA.BANK_BRANCH_ID = ABB.branch_party_id (+)
 and trx.receipt_method_id = meth.receipt_method_id (+)
 and PAYS.selected_for_receipt_batch_id is null
 and not exists
 (select 1
    from ra_customer_trx_lines sub,
         ar_payment_schedules ps
   where sub.br_ref_customer_trx_id = TRX.customer_trx_id
     and ps.customer_trx_id = trx.customer_trx_id
     and ( ( ps.amount_due_remaining = 0 and
             sub.customer_trx_id <> ' || customer_trx_id || ' )' ||
           ' OR (sub.customer_trx_id = ' || customer_trx_id || ' )))' ||
' and trx.invoice_currency_code = ' || br_currency ||
' and trx.trx_date <= ' || br_trxdate;

   /* modified for tca update */
   if PAY_UNRELATED_INVOICES = 'N' THEN
     -- Bug 8997911 [restricturd the sub query to improve perf.]
      AssignCurStr := AssignCurStr ||
        ' and (  trx.bill_to_customer_id = ' || drawee_id ||
	' OR exists (
		SELECT ''X''
		FROM hz_cust_acct_relate rr
		WHERE rr.cust_account_id = ' || drawee_id ||
	' and rr.related_cust_account_id = trx.bill_to_customer_id
          and rr.bill_to_flag = ''Y'' ' ||
		' UNION ALL' ||
       	' SELECT ''X''
            FROM ar_paying_relationships_v rel,
                 hz_cust_accounts acc
           WHERE rel.party_id = acc.party_id
	     AND rel.related_cust_account_id = trx.bill_to_customer_id
             AND acc.cust_account_id = ' || drawee_id ||
            ' AND ' || br_trxdate || ' BETWEEN effective_start_date
                                    AND effective_end_date)) ';

   end if;

   AssignCurStr:= AssignCurStr || pg_where_clause;

   /* get all BR transactions that can be assigned to this BR */
   /* bug 2473700 : for quick assign, show current balance due for invoices */
   /* modified for tca update */
AssignCurStr:=AssignCurStr||
'UNION Select
 TRX.trx_number,
 TRX.doc_sequence_value,
 TRX.trx_date,
 TRX.comments,
 TRX.purchase_order,
 TRX.invoice_currency_code,
 NULL,
 NULL,
 PAYS.amount_due_original,
 -- Bug 2473700 NULL,
 PAYS.amount_due_remaining,
 NULL,
 PAYS.due_date,
 PAYS.exchange_rate,
 PAYS.terms_sequence_number,
 PARTY.jgzz_fiscal_code,
 CUST_ACCT.account_number,
 substrb(party.party_name,1,50),
 CUST_ACCT.customer_class_code,
 PARTY.category_code,
 ARPT_SQL_FUNC_UTIL.get_lookup_meaning(''CUSTOMER_CATEGORY'', party.category_code),
 ARPT_SQL_FUNC_UTIL.get_trx_type_details(TRX.cust_trx_type_id,''NAME''),
 ARPT_SQL_FUNC_UTIL.get_lookup_meaning(''INV/CM'', types.type),
 ARPT_SQL_FUNC_UTIL.get_trx_type_details(TRX.cust_trx_type_id,''TYPE''),
 METH.name,
 METH.receipt_method_id,
 SITE.location,
 TRX.bill_to_site_use_id,
 ABB.bank_name,
 ABB.branch_party_id bank_branch_id,
 ABA.bank_account_id,
 NULL,
 NULL,
 TRX.customer_trx_id,  			/* br_ref_customer_trx_id */
 PAYS.payment_schedule_id,  		/* br_ref_payment_schedule_id */
 PAYS.amount_due_remaining,  		/* Extended Amount */
 PAYS.acctd_amount_due_remaining,  	/* Extended Acctd Amount */
 NULL					/* Customer_TRX_LINE_ID */
 FROM
 RA_CUST_TRX_TYPES	 TYPES,
 RA_CUSTOMER_TRX         TRX ,
 AR_PAYMENT_SCHEDULES    PAYS ,
 HZ_CUST_ACCOUNTS        CUST_ACCT ,
 HZ_PARTIES		 PARTY,
 AR_receipt_METHODS      METH,
 CE_BANK_BRANCHES_V      ABB,
 HZ_CUST_SITE_USES       SITE,
 ap_bank_accounts        ABA,
 AR_TRANSACTION_HISTORY  H
 where trx.legal_entity_id = ' || p_le_id ||
' and TRX.drawee_id = cust_acct.cust_account_id
 and cust_acct.party_id = party.party_id
 and TRX.customer_trx_id = PAYS.customer_trx_id
 and TRX.cust_trx_type_id = TYPES.cust_trx_type_id
 and PAYS.amount_due_remaining <> 0
 and PAYS.amount_due_remaining = TRX.br_amount
 and PAYS.selected_for_receipt_batch_id is null
 and SITE.SITE_USE_ID =  TRX.drawee_site_use_id
 and TRX.CUSTOMER_BANK_ACCOUNT_ID = ABA.BANK_ACCOUNT_ID (+)
 and ABA.BANK_BRANCH_ID = ABB.branch_party_id (+)
 and trx.receipt_method_id = meth.receipt_method_id (+)
 and H.customer_trx_id = TRX.customer_trx_id
 and H.current_record_flag    = ''Y''
 and H.status = ''UNPAID''
 and not exists
(select 1
   from ra_customer_trx_lines 	linesub,
        ar_payment_schedules 	paysub ,
        ra_customer_trx 	billsub
  where linesub.br_ref_customer_trx_id = TRX.customer_trx_id
    and linesub.customer_trx_id = billsub.customer_trx_id
    and billsub.customer_trx_id  = paysub.customer_trx_id
    and (paysub.reserved_type is not null OR billsub.br_on_hold_flag = ''Y''))
 and trx.invoice_currency_code = ' || br_currency ||
' and trx.trx_date <= ' || br_trxdate;

   /* modified for tca update */
   -- Bug 8997911 [restricturd the sub query to improve perf.]
   if PAY_UNRELATED_INVOICES='N' THEN
      AssignCurStr := AssignCurStr||
         ' and (  TRX.drawee_id = ' || drawee_id ||
	 ' OR EXISTS (
		SELECT ''X''
		FROM hz_cust_acct_relate rr
		WHERE rr.cust_account_id = ' || drawee_id ||
	' and rr.related_cust_account_id = trx.bill_to_customer_id
          and rr.bill_to_flag = ''Y'' ' ||
		' UNION ALL' ||
       	' SELECT ''X''
            FROM ar_paying_relationships_v rel,
                 hz_cust_accounts acc
           WHERE rel.party_id = acc.party_id
	     AND rel.related_cust_account_id = trx.bill_to_customer_id
             AND acc.cust_account_id = ' || drawee_id ||
            ' AND ' || br_trxdate || ' BETWEEN effective_start_date
                                    AND effective_end_date)) ';

   end if;

   AssignCurStr:=AssignCurStr||pg_where_clause||' '||pg_order_clause;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'AssignCurStr : ' || AssignCurStr);
   END IF;
   /* Now we retrieve all transactions that can be assigned to this BR */

   OPEN AssignCur FOR AssignCurStr;
   LOOP

      FETCH AssignCur INTO  TempAssignRec;
      EXIT WHEN AssignCur%NOTFOUND;

      NewTotal := TotalSoFar + NVL(TempAssignRec.Extended_amount , 0);

      /* Bug 1421967 Remove functionality to assign up to an amount */
      /* EXIT WHEN AssignmentAmount < NewTotal; */

      Assigntab(AssignCur%ROWCOUNT+ J ) := TempAssignRec;
      TotalSoFar := TotalSoFar + NVL(TempAssignRec.Extended_Amount , 0);

   END LOOP;

   Extended_total:=TotalSoFar;

   IF AssignCur%ROWCOUNT>0 THEN
      CLOSE AssignCur;
      RETURN TRUE;
   ELSE
      CLOSE AssignCur;
      RETURN FALSE;
   END IF;

END Fetch_assignments;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    revision                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the revision number of this package.             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | RETURNS    : Revision number of this package                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      10 JAN 2001 John HALL           Created                              |
 +===========================================================================*/
FUNCTION revision RETURN VARCHAR2 IS
BEGIN
  RETURN '$Revision: 120.10.12010000.4 $';
END revision;


END;

/
