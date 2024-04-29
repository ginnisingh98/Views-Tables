--------------------------------------------------------
--  DDL for Package Body FA_CUSTOM_RET_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUSTOM_RET_VAL_PKG" as
/* $Header: facrvcb.pls 120.3.12010000.2 2009/07/19 11:06:14 glchen ship $   */


FUNCTION VALIDATE_CRITERIA
	(px_mass_ret_rec	IN  FA_CUSTOM_RET_VAL_PKG.mass_ret_rec_type,
	 p_error_message	OUT NOCOPY varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS




  l_mass_ret_rec	fa_custom_ret_val_pkg.mass_ret_rec_type;

  Category_required	Exception;
  Location_required	Exception;
  Units_required	Exception;
  Group_asset_required 	Exception;

Begin


-- columns in fa_mass_retirements are now available
-- reference through l_mass_ret_rec.mass_retirement_id etc.
--

  l_mass_ret_rec :=  px_mass_ret_rec;

/* ACTIVATE AND CUSTOMIZE THIS SECTION IF ADDITIONAL
   VALIDATION IS WANTED IN Create Mass Retirements form
   OR IN Process Pending Retirements Criteria. */

--
/*
  IF l_mass_ret_rec.category_id is  null THEN
     	RAISE category_required;
  END IF;
*/
--
/*
  IF l_mass_ret_rec.location_id is null THEN
	     	RAISE location_required;
  END IF;
*/
/*
  IF l_mass_ret_rec.units is null THEN
	     	RAISE units_required;
  END IF;
*/
/*
  IF (l_mass_ret_rec.group_asset_id is null
      and l_mass_ret_rec.project_id is not null) THEN 		.
	     	RAISE group_asset_required;
  END IF;
*/

	Return TRUE;

Exception

-- rn determine method
-- potentially create new messages for all these without tokens

   WHEN category_required THEN
	  FND_MESSAGE.SET_NAME('OFA', 'FA_NULL_CATEGORY');
	  p_error_message := fnd_message.get;
      	  Return false;

   WHEN location_required THEN
	  FND_MESSAGE.SET_NAME('OFA','FA_NULL_LOCATION');
	  FND_MESSAGE.SET_TOKEN('LOCATION', 'FA_MASS_RETIREMENTS.LOCATION_ID', false);
	  p_error_message := fnd_message.get;
	  Return false;

   WHEN units_required THEN
	  FND_MESSAGE.SET_NAME('OFA','FA_NULL_FA_UNITS');
	  FND_MESSAGE.SET_TOKEN('ASSET_UNITS', 'FA_MASS_RETIREMENTS.UNITS_TO_RETIRE', false);
	  p_error_message := fnd_message.get;
	  Return false;

   WHEN group_asset_required THEN
	  FND_MESSAGE.SET_NAME('OFA','FA_NULL_GROUP_ASSETS');
	  p_error_message := fnd_message.get;
      	  Return false;

END VALIDATE_CRITERIA;
END FA_CUSTOM_RET_VAL_PKG;

/
