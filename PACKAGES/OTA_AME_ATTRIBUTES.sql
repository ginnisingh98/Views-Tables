--------------------------------------------------------
--  DDL for Package OTA_AME_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_AME_ATTRIBUTES" AUTHID CURRENT_USER AS
/* $Header: otamewkf.pkh 120.1 2005/06/09 04:13 dbatra noship $ */

--
-- ------------------------------------------------------------------------
-- |------------------------< Get_class_standard_price >----------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the event standard price
--
function get_class_standard_price
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;

-- ------------------------------------------------------------------------
-- |------------------------< get_Learning_path_name >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the learning path name
--
function get_Learning_path_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
-- ------------------------------------------------------------------------
-- |------------------------< get_course_primary_category >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the course primary category
--
function get_course_primary_category
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

--
-- ------------------------------------------------------------------------
-- |------------------------< Get_enrollment_status >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the enrollment status
--
function get_enrollment_status
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;


--
-- ------------------------------------------------------------------------
-- |------------------------< get_ofr_delivery_mode >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the delivery mode for the offering
--
function get_ofr_delivery_mode
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

-- ------------------------------------------------------------------------
-- |------------------------< get_course_name >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the course name
--
function get_course_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

-- ------------------------------------------------------------------------
-- |------------------------< get_offering_name >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the offering name
--
function get_offering_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

-- ------------------------------------------------------------------------
-- |------------------------< get_class_name >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the class name
--
function get_class_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

-- ------------------------------------------------------------------------
-- |------------------------< get_class_location >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the class location
--
function get_class_location
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;


	function get_cert_period_end_date
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;

	function get_cert_period_start_date
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

	function get_certification_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

	function get_certification_type
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

	function get_init_cert_comp_date
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;

	function get_init_cert_dur
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

	function get_renewal_duration
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;

	function get_validity_duration
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;


END ota_ame_attributes;

 

/
