--------------------------------------------------------
--  DDL for Package GMS_PO_API2_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_PO_API2_GRP" AUTHID CURRENT_USER as
--$Header: gmsgpo2s.pls 120.1 2005/07/26 14:22:20 appldev ship $


 TYPE tbl_num is table of number       index by binary_integer;
 TYPE tbl_v1  is table of varchar2(1)  index by binary_integer;
 TYPE tbl_v15 is table of varchar2(15) index by binary_integer;

 TYPE purge_in_rectype is record
 ( entity_name VARCHAR2(50),
   entity_ids  TBL_NUM
 );

 TYPE purge_out_rectype is record
 ( entity_ids TBL_NUM,
   action TBL_V1
 );



    -- start of comments
    -- --------------------
    -- Standard Parameters    : Standard parameters descriptions
    -- p_api_version	      : This parameter is used by the api to compare the version
    --				  numbers of incoming calls to its current version number.
    --				  return an unexpected error if they are incompatible.
    -- p_init_msg_list	      : This allows api called to request that the API does
    --                          the initialization of the message list on their behalf,
    --                          thus reducing the number of calls required by a caller
    --                          in order to execute an API.
    --
    -- p_commit	              : p_commit parameter is used by api caller to ask the API
    --                          to commit on their behalf after performing its function.
    --
    -- p_validation_level     : APIs use the parameter to determine which validation steps
    --                          should be executed and which steps should be skipped.
    --				  value 0 = none validations
    --                          value 100 = FULL validations.
    --
    -- x_return_status	      : out varchar2
    --                          represents the result of all the operations performed by
    --                          the API and must have one of the following values.
    --                          G_RET_STS_SUCCESS    = 'S'
    --                          G_RET_STS_ERROR      = 'E'
    --                          G_RET_STS_UNEXP_ERROR= 'U'
    --
    -- x_msg_count            : OUT NUMBER
    --                          the message count holds the number of messages in the
    --                          API message list. If this number is one then message data
    --                          holds the message in an encoded format.
    -- x_msg_data             : OUT number
    --                          message data holds the message in an encoded format.
    -- end of comments
    -- -----------------

    -- Start of comments
    -- -----------------
    -- API Name		: CREATE_ADLS
    -- Type		: This is a Public package program unit.
    -- Pre Reqs		: None
    -- Function		: This API is for creating Award Distribution Lines for new Purchase
    --			  Order Distributions created through Copy Document feature in PO.,
    --        2		: This API is for creating Award Distribution Lines for new Purchase
    --			  Order Distributions created through AUTOCREATE function
    --        3		: This API is for creating Award Distribution Lines for new Purchase
    --			  Order Distributions created through Create release concurrent process
    --                    function
    --
    -- Logic		: Copy award distribution line from the award set id passed.
    -- Calling API      : po_interface_s.create_distributions
    -- Calling API      : PO_RELGEN_PKG.create_release_distribution
    -- Calling API      : PO_COPYDOC_S1.insert_distribution
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
    --  IN                p_calling_module -
    --                      This tells calling API for create_adls.
    --                      COPYDOC, AUTOCREATE, CREATE_RELEASE, CHANGE_PO
    -- End of comments
    -- ----------------

    PROCEDURE CREATE_ADLS
        ( p_api_version      in           number,
          p_init_msg_list    in           varchar2,
          p_commit           in           varchar2,
          p_validation_level in           number,
          x_msg_count       out    nocopy number,
          x_msg_data        out    nocopy varchar2,
          x_return_status   out    nocopy varchar2,
          p_calling_module   in           varchar2,
          p_interface_obj   in out nocopy gms_po_interface_type)  ;


    -- Start of comments
    -- -----------------
    -- API Name         : validate_po_purge
    -- Type             : This is a Public package program unit.
    -- Pre Reqs         : None
    -- Function         : This api will determine if document can be purged
    --                    or not. The structure will hold the value 'N' to disallow
    --                    the purge.
    -- Logic            : A structure indicating whether PO documents can be purged
    --                    or corresponding entry in x_out_rec.purge_allowed will indicate
    --                    whether the document is purgable or not. e.g., If
    --                    x_out_rec.purge_allowedNi) is 'Y', it means that
    --                    the document specified in ip_in_rec.entity_ids(i) will not be purged.
    --                    The number of records in x_out_rec.purge_allowed should always
    --                    one that grants do not want to purge.

    -- Calling API      : ???????????
    -- Parameters       :
    --                  : Standard parameters
    --                    p_api_version, p_commit, p_init_msg_list,
    --                    p_validation_level, x_msg_count, x_msg_data,
    --                    x_return_status
    --IN OUT:
    --p_in_rec
    --                    A structure that holds PO information
    --                    p_in_rec.entity_name will expect 'PO_HEADERS',
    --                    while p_in_rec.entity_ids will be a table of all document
    --                    header ids that PO are about to be purged
    --OUT:
    --x_out_rec
    --                    A structure indicating whether PO documents can be purged
    --                    or corresponding entry in x_out_rec.purge_allowed will indicate
    --                    whether the document is purgable or not. e.g., If
    --                    x_out_rec.purge_allowedNi) is 'Y', it means that
    --                    the document specified in ip_in_rec.entity_ids(i) will not be purged.
    --                    The number of records in x_out_rec.purge_allowed should always
    --                    one that grants do not want to purge.
    -- End of comments
    -- ----------------
    PROCEDURE validate_po_purge ( p_api_version   IN         NUMBER,
                                  p_init_msg_list IN         VARCHAR2,
                                  p_commit        IN         VARCHAR2,
                                  p_validation_level IN      NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_in_rec        IN         PURGE_IN_RECTYPE,
                                  x_out_rec       OUT NOCOPY PURGE_OUT_RECTYPE
                                );


    -- Start of comments
    -- -----------------
    -- API Name         : po_purge
    -- Type             : This is a Public package program unit.
    -- Pre Reqs         : None
    -- Function         : This will delette award distribution lines.
    -- Logic            : p_in_rec will have list of po header ids that
    --                    need to be purged. Grants will delete the
    --                    corresponding award distribution lines.
    -- Calling API      : ???????????
    -- Parameters:
    -- IN:
    -- p_in_rec
    --                    A structure that holds PO information
    --                    p_in_rec.entity_name will expect 'PO_HEADERS', while
    --                    p_in_rec.entity_ids
    --                    will be a table of all document header ids that PO are
    --                    about to be purged
    -- End of comments
    -- -----------------

    PROCEDURE po_purge ( p_api_version   IN         NUMBER,
  			 p_init_msg_list IN         VARCHAR2,
                         p_commit        IN         VARCHAR2,
                         p_validation_level IN      NUMBER,
  			 x_return_status OUT NOCOPY VARCHAR2,
   			 x_msg_count     OUT NOCOPY NUMBER,
  			 x_msg_data      OUT NOCOPY VARCHAR2,
  			 p_in_rec        IN         PURGE_IN_RECTYPE
 		      );

    -- Start of comments
    -- -----------------
    -- API Name		: get_award_number
    -- Type		: This is a Public package program unit.
    -- Pre Reqs		: None
    -- Function		: This API is for deriving the award number for the award_set_id
    --                    passed to the api. This is used in PO Fundscheck code to
    --                    populate reference column in gl bc packet with award number.
    -- Logic		: get the award number from the adl and gms_awards_all..
    -- Calling API      : PO funds check code PL/SQL Version.
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN
    --			: p_award_set_id_tbl
    --                      The list of award set IDs.
    -- OUT                x_award_num_tbl
    --                      The list of award number sent out.
    -- End of comments
    -- ----------------
    PROCEDURE get_award_number ( p_api_version      in         NUMBER,
		                 p_init_msg_list    in         varchar2,
	                         p_commit           in         varchar2,
		                 p_validation_level in         NUMBER,
			         x_msg_count        out nocopy number,
			         x_msg_data         out nocopy varchar2,
			         x_return_status    out nocopy varchar2,
			         p_award_set_id_tbl IN         tbl_num,
			         x_award_num_tbl    OUT nocopy tbl_v15);
END GMS_PO_API2_GRP ;

 

/
