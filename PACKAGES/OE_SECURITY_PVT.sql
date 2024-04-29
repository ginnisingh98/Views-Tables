--------------------------------------------------------
--  DDL for Package OE_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SECURITY_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVSECS.pls 120.0 2005/06/01 02:21:04 appldev noship $ */

--  Start of Comments
--  API name
--  Type        PRIVATE
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := '';

-- Security Record Type
/*  Record   G_SECURITY_REC_TYPE
*/
TYPE G_SECURITY_REC_TYPE IS RECORD
   (
     User_id                  Number := null
    ,application_id           Number := 300
    ,responsibility_id        Number := NULL
    ,WF_Item_Type             Varchar2(30) := 'OEOL'
    ,WF_Item_Key              Varchar2(100) := null
    ,Attribute_Group          Varchar2(30) := null
    ,Attribute_Code           Varchar2(30) := null
    ,Operation_code           Varchar2(30) := null
    ,constraint_id            Number       := null
           -- constraint id of the processing constraints which prevent the
           -- operation from being performed
    ,constraint_type          Varchar2(30) := null
           -- 'BLOCK' -- Operation not allowed
           -- 'REQUIRE_REASON'changes require to specify reason
           -- 'REQUIRE_HISTORY' changes require a history to be recorded
           -- null if no constraints exists
   , resolving_activity_item_type Varchar2(30) := null
   , resolving_activity_name      Varchar2(30) := null
   , resolving_responsibility_id  Number       := null
   , err_code                    Varchar2(240)  := null
);
/* Procedure  ChkProcConstraints
** Usage  Check if any processing constraints exists for a given Object
**        / Attribute. Returns FND_API.G_TUE if the current operation is
**        allowed and does not have any processing constrints. Returns
**        FND_API.G_FALSE if the operation is not allowed. The column
**        p_sec_req.constraint_id holds the constrint_id of the constraint
**        preventing the operation and p_sec_req.constraint_type is set
**        to null if no constraints exists, Object for processing constraints
**        and User if the current user / responsibility does not have
**        authority to perform the operation
** Parameters
**      IN OUT NOCOPY p_sec_req
** OUT NOCOPY p_result FND_API.G_TRUE if no processing constraints

**                          FND_API.G_FALSE if processing constrints exit
** OUT NOCOPY p_sec_req.security_result OBJECT for processing constrints

**                          USER if the user does not have authoriy to perform
**                          Operation
*/
Procedure ChkProcConstraints(
           x_sec_req        IN OUT NOCOPY /* file.sql.39 change */ OE_SECURITY_PVT.G_SECURITY_REC_TYPE
,x_return_status OUT NOCOPY Varchar2

,x_result OUT NOCOPY Varchar2

,x_msg_data OUT NOCOPY Varchar2

,x_msg_count OUT NOCOPY Number

);

END;

 

/
