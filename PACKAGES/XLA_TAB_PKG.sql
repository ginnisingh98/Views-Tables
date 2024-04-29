--------------------------------------------------------
--  DDL for Package XLA_TAB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TAB_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbtab.pkh 120.0 2004/05/28 14:29:43 aquaglia ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_pkg                                                        |
|                                                                       |
| DESCRIPTION                                                           |
|    Transaction Account Builder Engine hook                            |
|                                                                       |
| HISTORY                                                               |
|    18-FEB-04 A.Quaglia      Created                                   |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| run                                                                   |
|                                                                       |
|   This program is called by the public wrapper xla_tab_pub_pkg.run.   |
|   It reads the current AMB Context Code from the profile option       |
|   SLA: Accounting Methods Builder Context.                            |
|   It checks whether the specified Transaction Account Definition      |
|   exists and reads the corresponding hash id.                         |
|   If Transaction Account Definition is not compiled it tries to       |
|   compile it once.                                                    |
|   It builds the package name corrersponding to the Transaction        |
|   Account Definition specified in the input parameters.               |
|   It invokes, through dynamic SQL, the trans_account_def_online or    |
|   the trans_account_def_batch procedure of the generated Transaction  |
|   Account Definition package. The procedure will then process the     |
|   data loaded into the Transaction Account Builder Interface.         |
|                                                                       |
|   The OUT parameter x_return_status can have the following values:    |
|   FND_API.G_RET_STS_SUCCESS;                                          |
|   FND_API.G_RET_STS_ERROR;                                            |
|   FND_API.G_RET_STS_UNEXP_ERROR;                                      |
|   The other OUT parameters follow the FND API standard.               |
|                                                                       |
+======================================================================*/


PROCEDURE run
          (
            p_api_version                  IN NUMBER
           ,p_application_id               IN NUMBER
           ,p_account_definition_type_code IN VARCHAR2
           ,p_account_definition_code      IN VARCHAR2
           ,p_transaction_coa_id           IN NUMBER
           ,p_mode                         IN VARCHAR2
           ,x_return_status                OUT NOCOPY VARCHAR2
           ,x_msg_count                    OUT NOCOPY NUMBER
           ,x_msg_data                     OUT NOCOPY VARCHAR2
          );

END xla_tab_pkg;
 

/
