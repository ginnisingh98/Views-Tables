--------------------------------------------------------
--  DDL for Package GMS_PO_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_PO_API_GRP" AUTHID CURRENT_USER as
--$Header: gmsgpoxs.pls 120.1 2005/08/30 17:44:26 aaggarwa noship $

    -- start of comments
    -- --------------------
    -- Standard Parameters : Standard parameters descriptions
    -- p_api_version		: This parameter is used by the api to compare the version
    --				  numbers of incoming calls to its current version number.
    --				  return an unexpected error if they are incompatible.
    -- p_init_msg_list	        : This allows api called to request that the API does
    --                            the initialization of the message list on their behalf,
    --                            thus reducing the number of calls required by a caller
    --                            in order to execute an API.
    --
    -- p_commit	                : p_commit parameter is used by api caller to ask the API
    --                            to commit on their behalf after performing its function.
    --
    -- p_validation_level       : APIs use the parameter to determine which validation steps
    --                            should be executed and which steps should be skipped.
    --				  value 0 = none validations
    --                            value 100 = FULL validations.
    --
    -- x_return_status	        : out varchar2
    --                            represents the result of all the operations performed by
    --                            the API and must have one of the following values.
    --                            G_RET_STS_SUCCESS    = 'S'
    --                            G_RET_STS_ERROR      = 'E'
    --                            G_RET_STS_UNEXP_ERROR= 'U'
    --
    -- x_msg_count              : OUT NUMBER
    --                            the message count holds the number of messages in the
    --                            API message list. If this number is one then message data
    --                            holds the message in an encoded format.
    -- x_msg_data               : OUT number
    --                            message data holds the message in an encoded format.
    -- end of comments
    -- -----------------

    -- Start of comments
    -- -----------------
    -- API Name		: CREATE_COPY_DOC_ADL
    -- Type		: This is a Public package program unit.
    -- Pre Reqs		: None
    -- Function		: This API is for creating Award Distribution Lines for new Purchase
    --			  Order Distributions created through Copy Document feature in PO.
    -- Logic		: Copy award distribution line from the award set id passed.
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN
    --			: p_distribution_id	NUMBER
    -- 			   Purchase order distribution line ID
    --			: p_distribution_num	NUMBER
    --			   Distribution line number
    -- 			: p_project_id		NUMBER
    --                     Project ID on the distribution line
    --                  : p_task_id		NUMBER
    --                     Task on distribution line
    --                  : p_award_set_id        NUMBER
    --                     Source award distribution line reference.
    -- End of comments
    -- ----------------

    PROCEDURE CREATE_COPY_DOC_ADL
        ( p_api_version       IN         NUMBER,
          p_commit            IN         VARCHAR2,
          p_init_msg_list     IN         VARCHAR2,
          p_validation_level  IN         NUMBER,
          x_msg_count         OUT NOCOPY NUMBER,
          x_msg_data          OUT NOCOPY VARCHAR2,
          x_return_status     OUT NOCOPY VARCHAR2,
          p_distribution_id   IN         NUMBER,
          p_distribution_num  IN         NUMBER,
          p_project_id        IN         NUMBER,
          p_task_id           IN         NUMBER,
          p_award_set_id      IN         NUMBER ) ;


    -- Start of comments
    -- -----------------
    -- API Name		: CREATE_AUTOCREATE_PO_ADL
    -- Type		: This is a Public package program unit.
    -- Pre Reqs		: None
    -- Function		: This API is for creating Award Distribution Lines for new Purchase
    --			  Order Distributions created through AUTOCREATE function
    -- Logic		: Copy award distribution line from the award set id passed using
    --			  bulk processing.
    -- Calling API      : po_interface_s.create_distributions
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN OUT
    --			: p_interface_obj gms_po_interface_type
    --                     This is a SQL object having a following table
    --			   elements.
    --                     distribution_id - Holds distribution ID
    --		           distribution_num  Holds distribution number
    --                     project_id        Holds Project ID
    --                     task_id           Holds Task ID
    --                     award_set_id_in   Holds Award Set Id Reference
    --                     award_set_id_out  Holds return value of new
    --                                       award distribution line
    --                                       reference.
    -- End of comments
    -- ----------------

     PROCEDURE CREATE_AUTOCREATE_PO_ADL
        ( p_api_version     in      NUMBER,
          p_commit          in      varchar2,
          p_init_msg_list   in      varchar2,
          p_validation_level in     NUMBER,
          x_msg_count       out nocopy number,
          x_msg_data        out nocopy varchar2,
          x_return_status   out nocopy varchar2,
          p_interface_obj   in out nocopy gms_po_interface_type) ;

    -- Start of comments
    -- -----------------
    -- API Name		: CREATE_RELEASE_ADL
    -- Type		: This is a Public package program unit.
    -- Pre Reqs		: None
    -- Function		: This API is for creating Award Distribution Lines for new Purchase
    --			  Order Distributions created through Create release concurrent process
    --                    function
    -- Logic		: Copy award distribution line from the award set id passed using
    --			  bulk processing.
    -- Calling API      : PO_RELGEN_PKG.create_release_distribution
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN OUT
    --			: p_interface_obj gms_po_interface_type
    --                     This is a SQL object having a following table
    --			   elements.
    --                     distribution_id - Holds distribution ID
    --		           distribution_num  Holds distribution number
    --                     project_id        Holds Project ID
    --                     task_id           Holds Task ID
    --                     award_set_id_in   Holds Award Set Id Reference
    --                     award_set_id_out  Holds return value of new
    --                                       award distribution line
    --                                       reference.
    -- End of comments
    -- ----------------
    PROCEDURE CREATE_RELEASE_ADL
        ( p_api_version     in      NUMBER,
          p_commit          in      varchar2,
          p_init_msg_list   in      varchar2,
          p_validation_level in     NUMBER,
          x_msg_count       out nocopy number,
          x_msg_data        out nocopy varchar2,
          x_return_status   out nocopy varchar2,
          p_interface_obj   in out nocopy gms_po_interface_type) ;

    -- =================================================================
    -- Function : GET_AWARD_NUMBER

    -- API to  return the award number

    -- Calling API : PO and REQ summary window post_query  triggers.

    -- define function purity WNDS, WNPS   for this function.

    -- **********Describe the parameters and return values.

    -- =================================================================

    -- Start of comments
    -- -----------------
    -- API Name		: GET_AWARD_NUMBER
    -- Function		: the function is used to get an award number for a given award set id.
    -- Logic		: Query awrad id from adl and get award number from gms awards table.
    -- IN
    --			: p_award_set_id NUMBER
    --                    ADL : Record identifier.
    -- End of comments
    -- ----------------
    FUNCTION GET_AWARD_NUMBER
        ( p_api_version       in         number,
          p_commit            in         varchar2,
          p_init_msg_list     in         varchar2,
          p_validation_level  in         number,
          x_msg_count         out nocopy number,
          x_msg_data          out nocopy varchar2,
          x_return_status     out nocopy varchar2,
          p_award_set_id      in         number) return varchar2;

    -- Start of comments
    -- -----------------
    -- API Name		: GET_AWARD_ID
    -- Type		: This is a Public package program unit.
    -- Return value     : NUMBER ( award_id )
    -- Pre Reqs		: None
    -- Function		: API will determine the value of award_id for the award_number
    --			  passed.
    -- Logic		: select the award id from gms_awards_all
    -- Calling API      : PO_PDOI_DISTRIBUTIONS_SV1 and PO_VENDORS_SV1
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN OUT
    --			: p_award_number varchar2
    --                    award number defined in the interface tables.
    -- End of comments
    -- ----------------


    FUNCTION GET_AWARD_ID
        ( p_api_version        IN         number,
          p_commit             IN         varchar2,
          p_init_msg_list      IN         varchar2,
          p_validation_level   IN         number,
          x_msg_count          out nocopy number,
          x_msg_data           out nocopy varchar2,
          x_return_status      out nocopy varchar2,
          p_award_number       IN         varchar2) return number  ;


    -- Start of comments
    -- -----------------
    -- API Name		: validate_transaction
    -- Type		: This is a Public package program unit.
    -- Pre Reqs		: None
    -- Function		: Validate award ,project task related standard validations
    --			  Validations are executed only if grants is enabled.
    --
    --                    a. Execute validations if grants is implemented.
    --                    b. Make sure that award is entered for a sponsored project.
    --                    c. Make sure that award is not entered for a no sponsored project.
    --                    d. Standard grants validations.
    -- Logic		: call gms standard validations.
    -- Calling API      : PO_PDOI_DISTRIBUTIONS_SV1 and PO_VENDORS_SV1
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN OUT
    --			:  p_project_id ( value of project id )
    --                     p_task_id    ( value of task id )
    --                     p_award_id   ( value of award id )
    --                     p_expenditure_type ( expenditure type )
    --                     p_expenditure_item_date ( expenditure item date )
    --                     p_calling_module ( package name.procedure name )
    -- End of comments
    -- ----------------
 PROCEDURE validate_transaction
        ( p_api_version           in         number,
          p_commit                in         varchar2,
          p_init_msg_list         in         varchar2,
          p_validation_level      in         number,
          x_msg_count             out nocopy number,
          x_msg_data              out nocopy varchar2,
          x_return_status         out nocopy varchar2,
          p_project_id            in         number,
          p_task_id               in         number,
          p_award_id              in         number,
          p_expenditure_type      in         varchar2,
          p_expenditure_item_date in         date,
          p_calling_module        in         varchar2) ;



    -- Start of comments
    -- -----------------
    -- API Name		: get_new_award_set_id
    -- Type		: This is a Public package program unit.
    -- Pre Reqs		: None
    -- Function		: Return award set id next sequence number.
    --                    return null when grants is not implemented.
    -- Logic		: get the next value of award set id sequence
    -- Calling API      : PO_PDOI_DISTRIBUTIONS_SV1 and PO_VENDORS_SV1
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- End of comments
    -- ----------------
  FUNCTION get_new_award_set_id return number  ;

    -- Start of comments
    -- -----------------
    -- API Name		: gms_enabled
    -- Type		: This is a Public package program unit.
    -- Pre Reqs		: None
    -- Function		: Return TRUE if grants is enabled
    --                    return FALSE if grants is not enabled.
    -- Logic		: check if grants is enabled or not.
    -- Calling API      : PO_PDOI_DISTRIBUTIONS_SV1 and PO_VENDORS_SV1
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- End of comments
    -- ----------------
  FUNCTION gms_enabled return boolean ;

    -- Start of comments
    -- -----------------
    -- API Name		: create_pdoi_adls
    -- Type		: This is a Public package program unit.
    -- Pre Reqs		: None
    -- Function		: create award distribution line for the passed award set id
    --                    and po distribution id.
    -- Logic		: create award distribution line.
    -- Calling API      : PO_PDOI_DISTRIBUTIONS_SV1 and PO_VENDORS_SV1
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN OUT
    --			:
    --                   p_distribution_id    value of po distribution id
    --                   p_distribution_num   value of distribution number
    --                   p_project_id         project id
    --                   p_task_id            task id
    --                   p_award_id           award id
    --                   p_award_set_id       award set id
    --
    -- End of comments
    -- ----------------
  PROCEDURE create_pdoi_adls
                ( p_api_version       IN         NUMBER,
                  p_commit            IN         VARCHAR2,
                  p_init_msg_list     IN         VARCHAR2,
                  p_validation_level  IN         NUMBER,
                  x_msg_count         OUT NOCOPY NUMBER,
                  x_msg_data          OUT NOCOPY VARCHAR2,
                  x_return_status     OUT NOCOPY VARCHAR2,
                  p_distribution_id   IN         NUMBER,
                  p_distribution_num  IN         NUMBER,
                  p_project_id        IN         NUMBER,
                  p_task_id           IN         NUMBER,
                  p_award_id          IN         NUMBER,
                  p_award_set_id      IN         NUMBER )  ;

    --
    -- GET_AWARD_NUMBER : the function overloading was created to get the award number in a
    -- SQL.
    --
    FUNCTION GET_AWARD_NUMBER
        ( p_award_set_id    in      number) return varchar2;

    -- Start of comments
    -- -----------------
    -- API Name		: CREATE_PO_ADL
    -- Function		: create award distribution line for a award related PO distributions.
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN
    --			: p_project_id	NUMBER, Project Identifier.
    --			: p_task_id 	NUMBER, Task Identifier.
    -- 			: p_award_number varchar2, Award Number
    --                  : p_po_distribution_id NUMBER, PO distribution Identifier
    -- OUT
    --                  : x_award_set_id_out NUMBER
    --                      ADL record identifier for the award information.
    -- End of comments
    -- ----------------
     PROCEDURE CREATE_PO_ADL
        ( p_api_version        in         number,
          p_commit             in         varchar2,
          p_init_msg_list      in         varchar2,
          p_validation_level   in         number,
          x_msg_count          out nocopy number,
          x_msg_data           out nocopy varchar2,
          x_return_status      out nocopy varchar2,
          p_project_id         in         number,
          p_task_id            in         number,
          p_award_number       in         varchar2,
          p_po_distribution_id in         number,
          x_award_set_id_out   out nocopy number ) ;


    -- Start of comments
    -- -----------------
    -- API Name		: MAINTAIN_PO_ADL
    -- Function		: Update award details on ADL associated with the PO distributions.
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN
    --			: p_project_id	NUMBER, Project Identifier.
    --			: p_task_id 	NUMBER, Task Identifier.
    -- 			: p_award_number varchar2, Award Number
    --                  : p_po_distribution_id NUMBER, PO distribution Identifier
    --                  : p_award_set_id_in NUMBER, ADL record identifier.
    -- OUT
    --                  : x_award_set_id_out NUMBER
    --                      ADL record identifier for the award information.
    --                      x_award_set_id_out will be same as p_award_set_id_in when no new adl is created.
    --                      x_award_set_id_out will be new value when new adl is created when PO distribution
    --                      mismatch or when null award to new award is entered.
    -- End of comments
    -- ----------------
     PROCEDURE MAINTAIN_PO_ADL
        ( p_api_version         in         number,
          p_commit              in         varchar2,
          p_init_msg_list       in         varchar2,
          p_validation_level    in         number,
          x_msg_count           out nocopy number,
          x_msg_data            out nocopy varchar2,
          x_return_status       out nocopy varchar2,
          p_award_set_id_in     in         number,
          p_project_id          in         number,
          p_task_id             in         number,
          p_award_number        in         varchar2,
          p_po_distribution_id  in         number,
          x_award_set_id_out    out nocopy number ) ;

    -- Start of comments
    -- -----------------
    -- API Name		: DELETE_PO_ADL
    -- Function		: delete the award distribution line for a given po distribution line.
    --                    ADL is deleted when PO distribution is deleted.
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN
    --			: p_award_set_id_in NUMBER
    --                     Award Set Identifier in ADL record.
    --                  : p_po_distribution_id NUMBER
    --                     PO distribution identifier.
    -- End of comments
    -- ----------------
     PROCEDURE DELETE_PO_ADL
        ( p_api_version       in         number,
          p_commit            in         varchar2,
          p_init_msg_list     in         varchar2,
          p_validation_level  in         number,
          x_msg_count         out nocopy number,
          x_msg_data          out nocopy varchar2,
          x_return_status     out nocopy varchar2,
          p_award_set_id_in    in        number,
          p_po_distribution_id in        number ) ;

	FUNCTION  IS_SPONSORED_PROJECT( p_project_id in NUMBER )
	return varchar2 ;

END GMS_PO_API_GRP ;

 

/
