--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE" AS
/* $Header: BOMSVATB.pls 120.3 2006/05/31 08:25:05 vhymavat noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMSVATB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate
--
--  NOTES
--
--  HISTORY
--
--  01-JUL-99   Rahul Chitko    Initial Creation
--
--  08-MAY-01   Refai Farook	EAM changes
--
--  08-JUL-01   Refai Farook	Support for '0' serial number(EAM changes)
--
--  04-SEP-01   Refai Farook    One To Many support changes
****************************************************************************/
	G_PKG_NAME	CONSTANT VARCHAR2(30) := 'Bom_Validate';

	/********************************************************************
	* Function	: Alternate_Designator
	* Returns	: Boolean
	* Parameters IN	: Alternate_bom_code
	*		  Organization_id
	* Parameters OUT: None
	* Purpose	: Function will verify if the alternate bom
	*		  designator exits. If it does then the function wil
	*		  return a TRUE otherwise a FALSE.
	*********************************************************************/
	FUNCTION Alternate_Designator(  p_alternate_bom_code	IN  VARCHAR2
			              , p_organization_id	IN  NUMBER
				      ) RETURN BOOLEAN
	IS
		l_dummy NUMBER;
	BEGIN
		SELECT 1
		  INTO l_dummy
		  FROM bom_alternate_designators
		 WHERE alternate_designator_code = p_alternate_bom_code
		   AND organization_id		= p_organization_id;

		RETURN TRUE;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN FALSE;

	END Alternate_Designator;


	/*******************************************************************
	* Function      : End_Item_Unit_Number
	* Parameters IN : p_From_End_Item_Unit_Number
	* Parameters OUT: Error Text which will be pouplated in case of an
	*                 unexpected error.
	*
	* Return        : True if the from end item unit number is valid else
	*		  False
	* Purpose       : Verify that the from end item unit number exists
	*                 in the table PJM_MODEL_UNIT_NUMBERS.
	*******************************************************************/
	FUNCTION End_Item_Unit_Number
	( p_from_end_item_unit_number IN  VARCHAR2
	, p_revised_item_id           IN  VARCHAR2
	, x_err_text                  IN OUT NOCOPY VARCHAR2 )
	RETURN BOOLEAN
	IS
		l_dummy         VARCHAR2(10);
	l_err_text      VARCHAR2(2000) := NULL;
	BEGIN

    		IF p_from_end_item_unit_number IS NULL OR
                   p_from_end_item_unit_number = FND_API.G_MISS_CHAR
    		THEN
        		RETURN TRUE;
    		END IF;

    		SELECT  'VALID'
    		INTO     l_dummy
    		FROM     pjm_unit_numbers
    		WHERE
                -- end_item_id = p_revised_item_id AND
                unit_number = p_from_end_item_unit_number;

    		RETURN TRUE;

		EXCEPTION

    			WHEN NO_DATA_FOUND THEN
        			RETURN FALSE;

    			WHEN OTHERS THEN
        			x_err_text :=
				'An unexpected error occured in ' ||
				G_PKG_NAME ||
				' and procedure From End Item Unit Number'
                      		|| SQLERRM ;

        			RETURN FALSE;

	END End_Item_Unit_Number;


	/********************************************************************
	* Function      : Wip_Supply_Type
	* Parameters IN : Wip_Supply_Type value
	* Parameters OUT: Error Text which will be populated in case of an
	*                 unexpected error.
	* Returns       : True if the Wip_supply_Type exist else False
	* Purpose       : Verify that the value of Wip_Supply_Type is valid,
	*		  by looking in the Table MFG_LOOKUPS with a Lookup
	*		  Type of 'WIP_SUPPLY'
	*********************************************************************/
	FUNCTION Wip_Supply_Type (  p_wip_supply_type   IN  NUMBER
                          	, x_err_text          IN OUT NOCOPY VARCHAR2 )
	RETURN BOOLEAN
	IS
		l_dummy                       VARCHAR2(10);
	BEGIN

    		IF p_wip_supply_type IS NULL OR
                   p_wip_supply_type = FND_API.G_MISS_NUM
    		THEN
        		RETURN TRUE;
    		END IF;

    		SELECT 'VALID'
      		INTO l_dummy
      		FROM mfg_lookups
     		WHERE lookup_code = p_wip_supply_type
       		AND lookup_type = 'WIP_SUPPLY' ;

    		RETURN TRUE;

		EXCEPTION

    			WHEN NO_DATA_FOUND THEN
        			RETURN FALSE;

    			WHEN OTHERS THEN
        			x_err_text :=
			'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and function Wip_Supply_Type' || SQLERRM ;

			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	END Wip_Supply_Type;

	/*******************************************************************
	* Function      : Asset_Group_Serial_Number
	* Parameters IN : p_Assembly_Item_Id
	* Parameters OUT: Error Text which will be pouplated in case of an
	*                 unexpected error.
	*
	* Return        : True if the serial number is valid else
	*		  False
	* Purpose       : Verify that the serial number is valid for the
	*                 asset group in the table MTL_SERIAL_NUMBERS.
	*******************************************************************/

        FUNCTION Asset_Group_Serial_Number
        ( p_assembly_item_id  IN NUMBER,
          p_organization_id   IN NUMBER,
          p_serial_number     IN  VARCHAR2,
          x_err_text         IN OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN IS

          l_dummy VARCHAR2(1);

        BEGIN

	  IF p_assembly_item_id IS NULL OR p_serial_number IS NULL THEN
            RETURN (FALSE);
          END IF;

          IF p_serial_number = '0' THEN
            RETURN (TRUE);
          END IF;

          SELECT 'x' INTO l_dummy FROM dual WHERE EXISTS (
            SELECT NULL FROM mtl_serial_numbers WHERE
             inventory_item_id = p_assembly_item_id AND
             current_organization_id = p_organization_id AND
             serial_number = p_serial_number);

         RETURN (TRUE);

         EXCEPTION WHEN NO_DATA_FOUND THEN
           RETURN (FALSE);

         WHEN OTHERS THEN
       	   x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and function Asset_Group_Serial_Number' || SQLERRM ;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       END Asset_Group_Serial_Number;


        /*******************************************************************
        * Function      : Is_Preferred_Structure
        * Parameters IN : p_Assembly_Item_Id
        * 		  p_organization_id
        * 		  p_alternate_bom_code
        * Parameters OUT: Error Text which will be pouplated in case of an
        *                 unexpected error.
        *
        * Return        : 'Y' if there exists no other preferred structure
        *			 of that type.
        *                 'N' if there exists another preferred structure
        * Purpose       :
        *******************************************************************/

        FUNCTION  Is_Preferred_Structure
        ( p_assembly_item_id  IN NUMBER,
          p_organization_id   IN NUMBER,
          p_alternate_bom_code IN  VARCHAR2,
          x_err_text         IN OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

		l_dummy VARCHAR2(1);

        BEGIN
          IF p_assembly_item_id IS NULL OR p_organization_id  IS NULL THEN
            RETURN 'N' ;
          END IF;

          SELECT 'x' INTO l_dummy FROM dual WHERE EXISTS (
          select NULL from bom_bill_of_materials a, bom_alternate_designators b
              where a.assembly_item_id = p_assembly_item_id
              and a.organization_id = p_organization_id
              and a.is_preferred = 'Y'
              and a.structure_type_id = b.structure_type_id
              and b.alternate_designator_code = p_alternate_bom_code );

          RETURN 'N';

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
           RETURN 'Y';

         WHEN OTHERS THEN
           x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and function Is Preferred Structure' || SQLERRM ;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END Is_Preferred_Structure;

        /*******************************************************************
        * Function      : Object_Exists
        * Parameters IN : p_object_type
        *                 p_object_name
        *
        * Return        : 'Y' if there exists no other preferred structure
        *                        of that type.
        *                 'N' if there exists another preferred structure
        * Purpose       : checks for the existence of object in database.
        *******************************************************************/

	FUNCTION Object_Exists(p_object_type VARCHAR2,p_object_name VARCHAR2)
	RETURN  VARCHAR2 IS
	  l_exists VARCHAR2(1) := 'N';
          schema_name VARCHAR2(5):='APPS';
	  CURSOR c_check_object(cp_object_type VARCHAR2, cp_object_name VARCHAR2)IS
	    SELECT 'Y'
	    FROM   all_objects
	    WHERE  object_type  = cp_object_type
            AND    owner = schema_name
	    AND    object_name  = cp_object_name
	    AND    status       = 'VALID';
	BEGIN
	  OPEN  c_check_object(cp_object_type => p_object_type
                      ,cp_object_name => p_object_name);

	  FETCH c_check_object INTO l_exists;
	  CLOSE c_check_object;

       RETURN l_exists;
      END Object_Exists;

END Bom_Validate;

/
