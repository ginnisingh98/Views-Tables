--------------------------------------------------------
--  DDL for Package WIP_VALIDATEMLHEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_VALIDATEMLHEADER_PVT" AUTHID CURRENT_USER as
 /* $Header: wipmlhvs.pls 120.0.12010000.3 2009/03/16 12:23:29 pfauzdar ship $ */

  -- do we need this? --
  po_warning_flag number;

  line_validation_error exception;

  --
  -- This procedure defaults and validates all the columns in wip_job_schedule_interface table.
  -- It does group validation where it can and does line validation otherwise. For a particular
  -- column, the default and validation logic might be splitted in two different places if it needs
  -- both line and group validation.
  -- The only exception is for column serialization_start_op. The default and validation has to be
  -- done after the routing explosion. We have two seperate APIs for this purpose.
  --
  procedure validateMLHeader(p_groupID         in number,
                             p_validationLevel in number,
                             x_returnStatus out nocopy varchar2,
                             x_errorMsg     out nocopy varchar2);

  --
  -- This procedure is not called during validatoin phase. It must be called after the explosion
  -- so work order will be populated with job operations.
  --
  procedure defaultSerializationStartOp(p_rowid  in rowid,
                                        p_rtgVal in number);

  --
  -- Unlike other procedure, this one has to be called after the explosion. We can only validate op related
  -- after the explosion and the possible details loading.
  --
  procedure validateSerializationStartOp(p_rowid    in rowid,
                                         x_returnStatus out nocopy varchar2,
                                         x_errorMsg     out nocopy varchar2);

  procedure setInterfaceError(p_rowid       in rowid,
                              p_interfaceID in number,
                              p_text        in varchar2,
                              p_type        in number);
end wip_validateMLHeader_pvt;

/
