--------------------------------------------------------
--  DDL for Package WIP_MASSLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MASSLOAD_PUB" AUTHID CURRENT_USER as
 /* $Header: wipmlpps.pls 120.1.12010000.1 2008/07/24 05:23:50 appldev ship $ */

  /* Pass 1 for p_commitFlag if you want this API to commit changes. Pass
   0 otherwise. */
  procedure massLoadJobs(p_groupID         in number,
                         p_validationLevel in number,
                         p_commitFlag      in number,
                         x_returnStatus out nocopy varchar2,
                         x_errorMsg     out nocopy varchar2);

  -- this API is used to create one job for the given interface id. Please note that there should be no
  -- other records under the same group id as the given interface id. This API will fail that case.
  -- also, the load type for this record must be create standard or non-std job.
  procedure createOneJob(p_interfaceID in number,
                         p_validationLevel in number,
                         x_wipEntityID out nocopy number,
                         x_returnStatus out nocopy varchar2,
                         x_errorMsg     out nocopy varchar2);
end wip_massload_pub;

/
