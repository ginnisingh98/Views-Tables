--------------------------------------------------------
--  DDL for Package PAY_BATCH_BALANCE_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_BALANCE_ADJ_PKG" AUTHID CURRENT_USER AS
/* $Header: pybbautl.pkh 120.2 2006/01/20 05:54 jabubaka noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< submit_conc_request >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This function is called from the BBA webadi interface to submit the
-- concurrent request for batch balance adjustment.
-- Returns the request if of the submitted request.
--
-- ----------------------------------------------------------------------------

function submit_conc_request
(
  p_business_group_id      in  number,
  p_mode                   in  varchar2,
  p_batch_id               in  number,
  p_wait                   in  varchar2 default 'N',
  p_act_parameter_group_id in  number   default null
) return number;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< batch_overall_status >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This function derives the overall stauts of the batch. The overall status
-- is not just the batch status but also considers the status of the
-- batch groups.
--
-- ----------------------------------------------------------------------------
function batch_overall_status (p_batch_id in  number)
return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< batch_group_overall_status >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This function derives the overall status of the batch group. The overall
-- status is not just the batch group status but also considers the status of
-- the batch lines.
--
-- ----------------------------------------------------------------------------
function batch_group_overall_status
  ( p_batch_id       in  number
   ,p_batch_group_id in  number )
return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< purge >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedures deletes all records associated with the batch balance
-- adjustment tables and the pay_message_lines table.
--
-- ----------------------------------------------------------------------------
--
procedure purge
  ( p_batch_id       in  number,
    p_batch_group_id in  number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_operation_allowed >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- Given the current batch status and the required processing mode this
-- function determines if its a valid operation or not.
--
-- ----------------------------------------------------------------------------
--
function check_operation_allowed
   ( p_batch_status in varchar2 ,
     p_process_mode in varchar2 )
return boolean;
------------------------------------------------------------------------------
-- |--------------------------------< rollback_batch >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedures rollbacks all the actions of the given batch id.
--
-- ----------------------------------------------------------------------------
--
procedure rollback_batch
  ( p_batch_id       in  number,
    p_batch_group_id in  number);
--
------------------------------------------------------------------------------
--|---------------------------< validate_and_transfer >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedures does validate or transfer based on the batch_process_mode
--   specified. This is internally called by validate and transfer
-- ----------------------------------------------------------------------------
--
procedure validate_and_transfer
   (p_batch_id       in  number,
    p_batch_group_id in  number,
    p_batch_process_mode varchar2);
--
------------------------------------------------------------------------------
-- |--------------------------------< transfer_batch >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure transfers the batch specified
--
-- ----------------------------------------------------------------------------
--
procedure transfer_batch
  ( p_batch_id       in  number,
    p_batch_group_id in  number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< validate_batch >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedures validates the batch specified
--
-- ----------------------------------------------------------------------------
--
procedure validate_batch
  ( p_batch_id       in  number,
    p_batch_group_id in  number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< run_process >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure is used in the executable of the bba process.
--
-- ----------------------------------------------------------------------------
--

procedure run_process
(errbuf                  out     nocopy varchar2,
 retcode                 out     nocopy number,
 p_batch_operation       in      varchar2,
 p_batch_id              in      number,
 p_batch_group_id        in      number
);
--
END PAY_BATCH_BALANCE_ADJ_PKG;

 

/
