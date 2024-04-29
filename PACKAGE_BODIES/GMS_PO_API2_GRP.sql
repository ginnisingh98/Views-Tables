--------------------------------------------------------
--  DDL for Package Body GMS_PO_API2_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PO_API2_GRP" as
--$Header: gmsgpo2b.pls 120.0 2005/05/29 12:17:11 appldev noship $

    -- Start of comments
    -- Declare package variables used for FND_API calls.
    -- End of comments
    -- ------------------

    G_api_version	CONSTANT NUMBER         := 1.0 ;
    G_pkg_name	        CONSTANT varchar2(45)   := 'GMS_PO_API2_GRP' ;
    G_file_name         CONSTANT varchar2(45)   := 'gmsgpo2b.pls';


    -- start of comments
    -- --------------------
    -- Standard Parameters    : Standard parameters descriptions
    -- p_api_version	      : This parameter is used by the api to compare the version
    --			        numbers of incoming calls to its current version number.
    --			        return an unexpected error if they are incompatible.
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
    --			        value 0 = none validations
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
    -- API Name		: common_code
    -- Type		: This is a private package program unit.
    -- Pre Reqs		: None
    -- Function		: This API is for validating standard API compatibility
    --                    checks.
    -- Calling API      : Local program units.
    -- Parameters 	:
    -- 			: Standard parameters
    --			  p_api_version, p_commit, p_init_msg_list,
    --			  p_validation_level, x_msg_count, x_msg_data,
    --			  x_return_status
    -- IN
    --			: p_api_name
    --                     The name of the API calling it.
    -- End of comments
    -- ----------------
   PROCEDURE common_code ( p_api_version      in         NUMBER,
                           p_init_msg_list    in         varchar2,
	                   p_commit           in         varchar2,
		           p_validation_level in         NUMBER,
			   x_msg_count        out nocopy number,
			   x_msg_data         out nocopy varchar2,
			   x_return_status    out nocopy varchar2,
                           p_api_name         IN         varchar2 ) is

      l_msg_count	NUMBER ;
      l_msg_data 	varchar2(2000) ;
      l_return_status   varchar2(1)   := fnd_api.G_RET_STS_SUCCESS;
   BEGIN

    	-- Standrad call to check API compatibility.
    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    p_api_name,
    					    G_pkg_name) THEN

    	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    	END IF ;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	--
    	IF FND_API.to_boolean( p_init_msg_list) THEN

    	   FND_MSG_PUB.initialize ;

    	END IF ;

    	-- Initialize API return status to success.
    	--
    	l_return_status  := FND_API.G_RET_STS_SUCCESS ;

    	--
    	-- Determine the validation level
    	--
    	IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN

    	   -- No validation logic required for this API.
    	   --
    	   NULL ;
    	END IF ;

    	-- Program logic begins here
	-- Program Logic ends here

           x_msg_count     := l_msg_count ;
           x_msg_data      := l_msg_data  ;
           x_return_status := l_return_status ;

    EXCEPTION
           WHEN FND_API.G_EXC_ERROR then
    	    x_return_status := FND_API.G_RET_STS_ERROR ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
					p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
					p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
           WHEN OTHERS THEN
    	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	    IF FND_MSG_PUB.check_msg_level( fnd_msg_pub.g_msg_lvl_unexp_error) THEN
    		fnd_msg_pub.add_exc_msg( G_pkg_name, p_api_name ) ;
    	    END IF ;

    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
					p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
   END common_code ;


    -- Start of comments
    -- -----------------
    -- API Name		: create_bulk_adl
    -- Type		: This is a private package program unit.
    -- Pre Reqs		: None
    -- Function		: This is used to create award distribution lines
    --                    using the bulk processing.
    -- Logic		: Loop thru all the elements of the object record
    --			  and create award distribution lines.
    -- Parameters 	:
    -- OUT 		: x_msg_count 	OUT	NUMBER
    --			                Holds no. of messages in the API
    --					message lists.
    --			: x_msg_data    OUT	Varchar2
    --					Holds the message in an encoded format.
    --			: x_return_status OUT	varchar2
    --					Holds the result of all the operations
    --					performed by the API.
    --					values - G_RET_STS_SUCESS = 'S'
    --					         G_RET_STS_ERROR  = 'E'
    --						 G_RET_STS_UNEXP_ERROR = 'U'
    --			: p_interface_obj IN OUT gms_po_interface_type
    --			    SQL object that holds the value of distribution_ID,
    --			    distribution number, project, task, award set id
    --			    for bulk processing.
    -- End of comments
    -- ----------------
    PROCEDURE create_bulk_adl
        (
          x_msg_count       out nocopy number,
          x_msg_data        out nocopy varchar2,
          x_return_status   out nocopy varchar2,
          p_interface_obj   in out nocopy gms_po_interface_type)  is

          l_dummy  NUMBER ;
    BEGIN

    x_return_status := fnd_api.G_RET_STS_SUCCESS ;

    IF NVL(p_interface_obj.distribution_id.COUNT,0) <= 0 then
	return ;
    END IF ;

    FORALL i in p_interface_obj.distribution_id.FIRST..p_interface_obj.distribution_id.LAST
         INSERT into gms_award_distributions
                (  award_set_id ,
                   adl_line_num,
                   funding_pattern_id,
                   distribution_value ,
	           raw_cost,
                   document_type,
                   project_id                 ,
                   task_id                    ,
                   award_id                   ,
                   expenditure_item_id        ,
                   cdl_line_num               ,
                   ind_compiled_set_id        ,
                   gl_date                    ,
                   request_id                 ,
                   line_num_reversed          ,
                   resource_list_member_id    ,
                   output_vat_tax_id          ,
                   output_tax_exempt_flag     ,
                   output_tax_exempt_reason_code  ,
                   output_tax_exempt_number   ,
                   adl_status                 ,
                   fc_status                  ,
                   line_type                  ,
                   capitalized_flag           ,
                   capitalizable_flag         ,
                   reversed_flag              ,
                   revenue_distributed_flag   ,
                   billed_flag                ,
                   bill_hold_flag             ,
                   distribution_id            ,
                   po_distribution_id         ,
                   invoice_distribution_id    ,
                   parent_award_set_id        ,
                   invoice_id                 ,
                   parent_adl_line_num         ,
                   distribution_line_number   ,
                   burdenable_raw_cost        ,
                   cost_distributed_flag      ,
                   last_update_date           ,
                   last_updated_by             ,
                   created_by                 ,
                   creation_date              ,
                   last_update_login          ,
                   billable_flag
           )
         SELECT gms_awards_dist_pkg.get_award_set_id  ,
                     1, --adl_line_num,
                   funding_pattern_id,
                   distribution_value ,
                   raw_cost,
                   'PO' , --document_type,
                   project_id                 ,
                   task_id                    ,
                   award_id                   ,
                   NULL, --expenditure_item_id        ,
                   cdl_line_num               ,
                   NULL, --ind_compiled_set_id        ,
                   gl_date                    ,
                   p_interface_obj.distribution_num(i), --request_id                 ,
                   line_num_reversed          ,
                   NULL, --resource_list_member_id    ,
                   output_vat_tax_id          ,
                   output_tax_exempt_flag     ,
                   output_tax_exempt_reason_code  ,
                   output_tax_exempt_number   ,
                   'A', --adl_status                 ,
                   'N', --fc_status                  ,
                   line_type                  ,
                   capitalized_flag           ,
                   capitalizable_flag         ,
                   reversed_flag              ,
                   revenue_distributed_flag   ,
                   billed_flag                ,
                   bill_hold_flag             ,
                   NULL, --distribution_id            ,
                   p_interface_obj.distribution_id(i), --po_distribution_id         ,
                   NULL, --invoice_distribution_id    ,
                   parent_award_set_id        ,
                   NULL, --invoice_id                 ,
                   parent_adl_line_num         ,
                   NULL, --distribution_line_number   ,
                   NULL, --burdenable_raw_cost        ,
                   cost_distributed_flag      ,
                   SYSDATE, --last_update_date           ,
                   fnd_global.user_id , --last_updated_by             ,
                   fnd_global.user_id , --created_by                 ,
                   SYSDATE, --creation_date              ,
                   last_update_login          ,
         	    billable_flag
     from gms_award_distributions
     where award_set_id =   p_interface_obj.award_set_id_in(i)
       and adl_line_num = 1 ;

     FOR i in 1..p_interface_obj.distribution_id.count LOOP

            select award_set_id
              into l_dummy
              from gms_award_distributions
             where po_distribution_id = p_interface_obj.distribution_id(i)
               and document_type = 'PO'
               and adl_status = 'A'
               and fc_status = 'N'  ;

            p_interface_obj.award_set_id_out(i) := l_dummy ;

     END LOOP;

   END create_bulk_adl;



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
          p_interface_obj   in out nocopy gms_po_interface_type)  is

          l_msg_count	    NUMBER ;
          l_msg_data 	    varchar2(4000) ;
          l_return_status  varchar2(1)   := fnd_api.G_RET_STS_SUCCESS;
          l_api_name        varchar2(45) := 'create_adls' ;
    begin

       -- API standards requires a standard code to validate
       -- api versions and init message list etc.
       -- Common code must be added to all the program unit.
       --
       common_code ( p_api_version ,
                     p_init_msg_list,
	             p_commit       ,
	             p_validation_level ,
		     l_msg_count    ,
		     l_msg_data     ,
		     l_return_status ,
                     l_api_name ) ;

    	-- Program logic begins here
	-- Program Logic ends here

	IF not gms_install.enabled then
	   return ;
	END IF ;

        IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
           -- =================================================
	   -- Bulk processing to create award distribution
	   -- lines.
	   -- =================================================
           create_bulk_adl
           ( l_msg_count ,
             l_msg_data  ,
             l_return_status ,
             p_interface_obj )  ;

	END IF ;

        x_msg_count     := l_msg_count ;
        x_msg_data      := l_msg_data  ;
        x_return_status := l_return_status ;

    end CREATE_ADLS ;
    -- =====================

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
          			  p_validation_level in      NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_in_rec        IN         PURGE_IN_RECTYPE,
                                  x_out_rec       OUT NOCOPY PURGE_OUT_RECTYPE
                                ) is

          l_msg_count	    NUMBER ;
          l_msg_data 	    varchar2(4000) ;
          l_return_status   varchar2(1)   := fnd_api.G_RET_STS_SUCCESS;
          l_api_name        varchar2(45)  := 'validate_po_purge' ;
    begin

       -- Standrad call to check API compatibility.
       -- API standards requires a standard code to validate
       -- api versions and init message list etc.
       -- Common code must be added to all the program unit.
       --
       common_code ( p_api_version ,
                     p_init_msg_list,
	             p_commit       ,
	             p_validation_level ,
		     l_msg_count    ,
		     l_msg_data     ,
		     l_return_status ,
                     l_api_name ) ;

    	-- Program logic begins here
	-- Program Logic ends here

        -- x_out_rec
        -- Notice that purge_out_rectype will have entity_ids table as well, specifying the documents
        -- that the caller needs to take "action" for, while action specifies the type of action. The stubbed
        -- procedure will not need to set anything to this OUT parameter at all (nor will the PO
        -- Purge program before calling validate_purge); but when the actual code is being implemented
        -- in this procedure, for now the requirement is to populate entity_ids with documents GMS does
        -- not allow to purge, with value 'N' in the corresponding entry in action. PO will not purge documents
        -- coming out form x_out_rec.entity_ids, with the corresponding action = 'N'.


	-- NOTHING IS POPULATED IN OUT PARAM THIS MEANS GRANTS OKAY WITH EVERYTHING IS
	-- PURGEABLE.

           x_msg_count     := l_msg_count ;
           x_msg_data      := l_msg_data  ;
           x_return_status := l_return_status ;

    END validate_po_purge ;


    -- Start of comments
    -- -----------------
    -- API Name         : po_purge
    -- Type             : This is a Public package program unit.
    -- Pre Reqs         : None
    -- Function         : This will delette award distribution lines.
    -- Logic            : A structure indicating whether PO documents can be purged
    --                    or not For each entry in p_in_rec.entity_ids, the
    --                    corresponding entry in x_out_rec.purge_allowed will indicate
    --                    whether the document is purgable or not. e.g., If
    --                    x_out_rec.purge_allowed(i) is 'Y', it means that
    --                    p_in_rec.entity_ids(i) can be purged.
    --                    If x_out_rec.purge_allowed(i) is 'N', the document specified in
    --                    p_in_rec.entity_ids(i) will not be purged.
    --                    The number of records in x_out_rec.purge_allowed should always
    --                    be the  same as that for p_in_rec.entity_ids

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

    PROCEDURE po_purge ( p_api_version  IN        NUMBER,
  			 p_init_msg_list IN        VARCHAR2,
                         p_commit        IN        VARCHAR2,
                         p_validation_level IN     NUMBER,
  			 x_return_status OUT NOCOPY VARCHAR2,
   			 x_msg_count    OUT NOCOPY NUMBER,
  			 x_msg_data      OUT NOCOPY VARCHAR2,
  			 p_in_rec        IN        PURGE_IN_RECTYPE
 		      ) is
          l_msg_count	    NUMBER ;
          l_msg_data 	    varchar2(4000) ;
          l_return_status   varchar2(1)   := fnd_api.G_RET_STS_SUCCESS;
          l_api_name        varchar2(45) := 'po_purge' ;
    begin

       -- Standrad call to check API compatibility.
       -- API standards requires a standard code to validate
       -- api versions and init message list etc.
       -- Common code must be added to all the program unit.
       --
       common_code ( p_api_version ,
                     p_init_msg_list,
	             p_commit       ,
	             p_validation_level ,
		     l_msg_count    ,
		     l_msg_data     ,
		     l_return_status ,
                     l_api_name ) ;

        IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
	   -- Program logic begins here
	   IF  p_in_rec.entity_ids.COUNT > 0 THEN
	       FORALL i in p_in_rec.entity_ids.first.. p_in_rec.entity_ids.last
		      delete from gms_award_distributions adl
		       where ( award_set_id , po_distribution_id) in
				  ( select pod.award_id, po_distribution_id
				      from po_distributions_all  pod
				     where pod.po_header_id = p_in_rec.entity_ids(i)
				       and pod.award_id is not NULL )
		      and document_type = 'PO' ;
	   END IF ;
	END IF ;
	-- Program Logic ends here

        x_msg_count     := l_msg_count ;
        x_msg_data      := l_msg_data  ;
        x_return_status := l_return_status ;

   END PO_PURGE ;


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
			         x_award_num_tbl    OUT nocopy tbl_v15) is

          l_msg_count	    NUMBER ;
          l_msg_data 	    varchar2(2000) ;
          l_return_status   varchar2(1)   := fnd_api.G_RET_STS_SUCCESS;
          l_api_name        varchar2(45) := 'get_award_number' ;
	  l_award_set_id    NUMBER ;
	  l_award_number    gms_awards_all.award_number%TYPE ;
	  l_count           NUMBER ;
    begin

       -- Standrad call to check API compatibility.
       -- API standards requires a standard code to validate
       -- api versions and init message list etc.
       -- Common code must be added to all the program unit.
       --
       common_code ( p_api_version ,
                     p_init_msg_list,
	             p_commit       ,
	             p_validation_level ,
		     l_msg_count    ,
		     l_msg_data     ,
		     l_return_status ,
                     l_api_name ) ;

    	-- Program logic begins here
       IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
          IF p_award_set_id_tbl.count > 0 THEN

	       FOR l_index in 1..p_award_set_id_tbl.count LOOP
	           l_award_set_id := p_award_set_id_tbl(l_index) ;
	           l_count        := l_index ;

	           select awd.award_number
		     into l_award_number
		     from gms_awards_all awd, gms_award_distributions adl
                    where adl.award_set_id = l_award_set_id
		      and adl.award_id     = awd.award_id ;

                    x_award_num_tbl(l_index) := l_award_number ;

	       END LOOP ;
          END IF ;
       END IF ;
       -- Program Logic ends here
       x_msg_count     := l_msg_count ;
       x_msg_data      := l_msg_data  ;
       x_return_status := l_return_status ;

   EXCEPTION
       WHEN OTHERS THEN
    	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	    IF FND_MSG_PUB.check_msg_level( fnd_msg_pub.g_msg_lvl_unexp_error) THEN
    		fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;

    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
					p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
   END get_award_number ;

END GMS_PO_API2_GRP ;


/
