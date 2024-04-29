--------------------------------------------------------
--  DDL for Package Body GMS_PO_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PO_API_GRP" as
--$Header: gmsgpoxb.pls 120.3 2006/03/29 21:09:33 bkattupa noship $

    -- Start of comments
    -- Declare package variables used for FND_API calls.
    -- End of comments
    -- ------------------

    G_api_version	CONSTANT NUMBER         := 1.0 ;
    G_pkg_name	        CONSTANT varchar2(45)   := 'GMS_PO_API_GRP' ;
    G_file_name         CONSTANT varchar2(45)   := 'gmspox1b.pls';


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
                   output_tax_classification_code          ,
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
                   output_tax_classification_code          ,
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

    -- ==================


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
          p_award_set_id      IN         NUMBER ) is

      l_adls_rec       gms_award_distributions%ROWTYPE;
      l_cursor_found   boolean ;
      l_msg_count      NUMBER ;
      l_msg_data       varchar2(2000) ;
      l_return_status  varchar2(1) ;
      l_api_name       varchar2(50) :=  'create_copy_doc_adl' ;

      cursor c_adl is
    	 select *
    	   from gms_award_distributions
    	  where award_set_id = p_award_set_id
    	    and adl_line_num = 1 ;
    begin
    	-- Standrad call to check API compatibility.

    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
    					    G_pkg_name ) THEN

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

    	if p_award_set_id is NULL then
	   return ;
        end if ;

    	--
    	-- Get the award distribution line.
    	--

    	open c_adl ;
    	fetch c_adl into l_adls_rec ;
    	l_cursor_found := c_adl%FOUND ;
    	close c_adl ;

    	--
    	-- Check error if ADL doesn't exists.
    	--

    	if l_cursor_found = FALSE THEN
    		-- Error processing and return from here.
    		--
    		FND_MESSAGE.set_name('GMS', 'GMS_ADL_NOT_FOUND') ;
    		FND_MSG_PUB.add ;
    		RAISE FND_API.G_EXC_ERROR ;
    	end if ;

    	--
    	-- ADL creation starts here
    	--

    	IF NVL(l_adls_rec.po_distribution_id,0) <> p_distribution_id THEN
    	   -- Award distribution line must be created here.
    	   l_adls_rec.award_set_id	:= gms_awards_dist_pkg.get_award_set_id  ;
    	   l_adls_rec.adl_line_num	:= 1 ;
    	   l_adls_rec.document_type	:= 'PO' ;
    	   l_adls_rec.project_id	:= p_project_id ;
    	   l_adls_rec.task_id		:= p_task_id ;
    	   l_adls_rec.request_id        := p_distribution_num ;
    	   l_adls_rec.adl_status		:= 'A' ;
    	   l_adls_rec.fc_status		:= 'N' ;

    	   l_adls_rec.distribution_id	       := NULL ;
    	   l_adls_rec.invoice_id	       := NULL ;
    	   l_adls_rec.distribution_line_number := NULL ;
    	   l_adls_rec.invoice_distribution_id  := NULL ;
    	   l_adls_rec.expenditure_item_id      := NULL ;
    	   l_adls_rec.po_distribution_id       := p_distribution_id ;

    	   l_adls_rec.burdenable_raw_cost      := NULL ;

    	   l_adls_rec.creation_date	       := SYSDATE ;
    	   l_adls_rec.last_update_date         := SYSDATE ;
    	   l_adls_rec.last_updated_by	       := fnd_global.user_id ;
    	   l_adls_rec.created_by   	       := fnd_global.user_id ;

    	   gms_awards_dist_pkg.create_adls(l_adls_rec) ;

	   update po_distributions_all
	      set award_id  = l_adls_rec.award_set_id
	    where po_distribution_id = p_distribution_id ;

    	   --po_distributions_grp.update_award_id_po( p_api_version => p_api_version,
    	--					    p_commit      => p_commit,
    	--					    p_init_msg_list => p_init_msg_list,
    	--					    p_validation_level => p_validation_level,
    	--					    x_msg_count        => l_msg_count,
    	--					    x_msg_data         => l_msg_data,
    	--					    x_return_status    => l_return_status,
    	--					    p_award_set_id     => l_adls_rec.award_set_id,
    	--					    p_distribution_id  => p_distribution_id ) ;
   --


    	END IF ;

    	x_msg_count     := l_msg_count ;
    	x_msg_data      := l_msg_data ;
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
    		fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
    end CREATE_COPY_DOC_ADL ;
    -- ===========================

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
        ( p_api_version      in           number,
          p_commit           in           varchar2,
          p_init_msg_list    in           varchar2,
          p_validation_level in           number,
          x_msg_count       out    nocopy number,
          x_msg_data        out    nocopy varchar2,
          x_return_status   out    nocopy varchar2,
          p_interface_obj   in out nocopy gms_po_interface_type) is

          l_msg_count	    number    ;
          l_msg_data 	    varchar2(2000) ;
          l_return_status   varchar2(1) ;
          l_api_name        varchar2(45) := 'create_autocreate_po_adl' ;
    begin

    	-- Standrad call to check API compatibility.
    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
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

            create_bulk_adl ( x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data,
    			  x_return_status => l_return_status,
    			  p_interface_obj => p_interface_obj ) ;

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
    		fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;

    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
    end CREATE_AUTOCREATE_PO_ADL ;

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
        ( p_api_version      in           number,
          p_commit           in           varchar2,
          p_init_msg_list    in           varchar2,
          p_validation_level in           number,
          x_msg_count       out    nocopy number,
          x_msg_data        out    nocopy varchar2,
          x_return_status   out    nocopy varchar2,
          p_interface_obj   in out nocopy gms_po_interface_type)  is

          l_msg_count	    NUMBER ;
          l_msg_data 	    varchar2(2000) ;
          l_return_status   varchar2(1) ;
          l_api_name        varchar2(45) := 'create_release_adl' ;
    begin

    	-- Standrad call to check API compatibility.
    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
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

            create_bulk_adl ( x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data,
    			  x_return_status => l_return_status,
    			  p_interface_obj => p_interface_obj ) ;

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
    		fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;

    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
    end CREATE_RELEASE_ADL ;


    -- =====================

    -- Function : GET_AWARD_NUMBER

    -- API to  return the award number

    -- Calling API : PO and REQ summary window post_query  triggers.

    -- define function purity WNDS, WNPS   for this function.

    FUNCTION GET_AWARD_NUMBER
        ( p_api_version      in         number,
          p_commit           in         varchar2,
          p_init_msg_list    in         varchar2,
          p_validation_level in         number,
          x_msg_count        out nocopy number,
          x_msg_data         out nocopy varchar2,
          x_return_status    out nocopy varchar2,
          p_award_set_id     in         number) return varchar2 is

          l_msg_count	    number ;
          l_msg_data 	    varchar2(2000) ;
          l_return_status   varchar2(1) ;
          l_api_name        varchar2(45) := 'get_award_number' ;

          l_award_number    gms_awards_all.award_number%TYPE ;

          cursor c1 is
            select awd.award_number
              from gms_awards_all awd,
                   gms_award_distributions adl
             where adl.award_id     = awd.award_id
	       and adl.award_set_id = p_award_set_id
	       and adl.adl_line_num = 1 ;
    begin

    	-- Standrad call to check API compatibility.
    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
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
    	IF p_award_set_id is NULL then
    	   return NULL ;
    	END IF ;

    	open c1 ;
    	fetch c1 into l_award_number ;

    	IF c1%notfound then
    	   close c1 ;
    	   raise no_data_found ;
    	END IF ;

    	close c1 ;

    	x_return_status := l_return_status;

  	return l_award_number ;

    EXCEPTION
        WHEN OTHERS THEN
    	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	    IF FND_MSG_PUB.check_msg_level( fnd_msg_pub.g_msg_lvl_unexp_error) THEN
    		fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;

    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
    end GET_AWARD_NUMBER ;
    --  ==================


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
          p_award_number       IN         varchar2) return number  is

      l_award_id       NUMBER ;
      l_msg_count      NUMBER ;
      l_msg_data       varchar2(2000) ;
      l_return_status  varchar2(1)  := fnd_api.G_RET_STS_SUCCESS;
      l_api_name       varchar2(50) :=  'get_award_id' ;
      l_gms_enabled    BOOLEAN ;

    BEGIN
       -- STUB API for PO.
       --


    	-- Standrad call to check API compatibility.

    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
    					    G_pkg_name ) THEN

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

       l_gms_enabled := gms_install.enabled ;

       IF NOT l_gms_enabled THEN
	  return l_award_id ;
       END IF ;

	IF p_award_number is NULL THEN
           return l_award_id ;
	END IF ;

	select award_id
	  into l_award_id
	  from gms_awards_all
         where award_number = p_award_number ;

    	x_msg_count     := l_msg_count ;
    	x_msg_data      := l_msg_data ;
    	x_return_status := l_return_status ;
	return l_award_id ;
    EXCEPTION
	   WHEN NO_DATA_FOUND THEN
                x_return_status :=  FND_API.G_RET_STS_ERROR ;
	        FND_MESSAGE.set_name('GMS', 'GMS_INVALID_AWARD') ;
	        FND_MSG_PUB.add ;
    	        FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					    p_data    => x_msg_data ) ;

	        RETURN l_award_id ;

           WHEN FND_API.G_EXC_ERROR then
    	    x_return_status := FND_API.G_RET_STS_ERROR ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;

	    RETURN l_award_id ;

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
	    RETURN l_award_id ;

           WHEN OTHERS THEN

    	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	    IF FND_MSG_PUB.check_msg_level( fnd_msg_pub.g_msg_lvl_unexp_error) THEN
    		fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
	    RETURN l_award_id ;
    END GET_AWARD_ID ;


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
    -- BUG:4739557 x_return_status not initialized in validate_transactions.
    --
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
          p_calling_module        in         varchar2) is

      l_msg_count      NUMBER ;
      l_msg_data       varchar2(2000) ;
      l_return_status  varchar2(1)  := fnd_api.G_RET_STS_SUCCESS;
      l_api_name       varchar2(50) :=  'validate_transaction' ;
      l_sponsored_flag varchar2(1) ;
      l_gms_enabled    BOOLEAN ;
      l_spon_project   BOOLEAN ;
      l_project_type_class_code pa_project_types_all.project_type_class_code%TYPE ;

      cursor C_spon_project is
	     select gpt.sponsored_flag   , pt.project_type_class_code
	       from pa_projects_all p,
		    gms_project_types gpt ,
		    pa_project_types  pt
              where p.project_id = NVL(p_project_id,0)
		and p.project_type = gpt.project_type
		and p.project_type = pt.project_type ;

  BEGIN

    	-- Standrad call to check API compatibility.

    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
    					    G_pkg_name ) THEN

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
        -- ----------------
        -- BUG:4739557 x_return_status not initialized in validate_transactions.
        --
        x_return_status  := l_return_status ;

    	--
    	-- Determine the validation level
    	--
    	IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN

    	   -- No validation logic required for this API.
    	   --
    	   NULL ;
    	END IF ;

       l_gms_enabled := GMS_INSTALL.enabled ;
       l_spon_project := FALSE ;

       open C_spon_project ;
       fetch C_spon_project into l_sponsored_flag , l_project_type_class_code;
       close C_spon_project ;

       IF NVL(l_sponsored_flag,'N') = 'Y' THEN
	  l_spon_project := TRUE ;
       END IF ;

       IF  l_spon_project then
	  IF p_award_id is  null THEN
		  x_return_status :=  FND_API.G_RET_STS_ERROR ;
		  FND_MESSAGE.set_name('GMS', 'GMS_AWARD_REQUIRED') ;
		  FND_MSG_PUB.add ;
		  RAISE FND_API.G_EXC_ERROR ;
	  END IF ;
       ELSE
	  IF p_award_id is not NULL THEN

		  x_return_status :=  FND_API.G_RET_STS_ERROR ;
		  FND_MESSAGE.set_name('GMS', 'GMS_AWARD_NOT_ALLOWED') ;
		  FND_MSG_PUB.add ;
		  RAISE FND_API.G_EXC_ERROR ;
	  ELSE
		  RETURN ;
	  END IF ;
       END IF ;


       IF not l_gms_enabled THEN
	  return ;
       END IF ;

       if l_project_type_class_code = 'CONTRACT' then
	  x_return_status :=  FND_API.G_RET_STS_ERROR ;
  	  fnd_message.set_name('GMS','GMS_IP_INVALID_PROJ_TYPE');
          FND_MSG_PUB.add ;
    	  RAISE FND_API.G_EXC_ERROR ;
	end if;

	gms_transactions_pub.validate_transaction(p_project_id => p_project_id,
						  p_task_id => p_task_id,
						  p_award_id => p_award_id,
						  p_expenditure_type => p_expenditure_type,
						  p_expenditure_item_date => p_expenditure_item_date,
						  p_calling_module => 'TXNVALID',
						  p_outcome => l_msg_data );
	IF l_msg_data is NOT NULL then

	  x_return_status :=  FND_API.G_RET_STS_ERROR ;
  	  fnd_message.set_name('GMS',l_msg_data );
          FND_MSG_PUB.add ;
    	  RAISE FND_API.G_EXC_ERROR ;

	END IF ;

    	x_msg_count     := l_msg_count ;
    	x_msg_data      := l_msg_data ;
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
    		fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
  END validate_transaction ;


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
  FUNCTION get_new_award_set_id return number  is
     l_award_set_id NUMBER ;
  BEGIN
      IF gms_install.enabled then
         l_award_set_id := gms_awards_dist_pkg.get_award_set_id  ;
      END IF ;
      return l_award_set_id  ;
  END get_new_award_set_id ;


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
  FUNCTION gms_enabled return boolean is
    l_gms_enabled BOOLEAN := FALSE ;
  BEGIN

    l_gms_enabled := gms_install.enabled ;

    return l_gms_enabled ;

  END gms_enabled ;

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
                  p_award_set_id      IN         NUMBER )  is

      l_msg_count      NUMBER ;
      l_msg_data       varchar2(2000) ;
      l_return_status  varchar2(1)  := fnd_api.G_RET_STS_SUCCESS;
      l_api_name       varchar2(50) :=  'create_pdoi_adls' ;
      l_adl_rec        gms_award_distributions%ROWTYPE;
      l_gms_enabled          BOOLEAN ;

   BEGIN
     --
     -- STUB API
     --
    	-- Standrad call to check API compatibility.

    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
    					    G_pkg_name ) THEN

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

	l_gms_enabled := gms_install.enabled ;

	IF not l_gms_enabled then
	  return ;
        END IF ;

	IF  p_award_id is null THEN
	   return ;
	END IF ;

	l_adl_rec.expenditure_item_id	 := NULL ;
	l_adl_rec.project_id 		 := P_project_id;
	l_adl_rec.task_id   		 := p_task_id;
	l_adl_rec.cost_distributed_flag	 := 'N';
	l_adl_rec.cdl_line_num           := NULL;
	l_adl_rec.adl_line_num           := 1;
	l_adl_rec.distribution_value     := 100 ;
	l_adl_rec.line_type              := 'R';
	l_adl_rec.adl_status             := 'A';
	l_adl_rec.document_type          := 'PO';
	l_adl_rec.billed_flag            := 'N';
	l_adl_rec.bill_hold_flag         := NULL ;
	l_adl_rec.award_set_id           := p_award_set_id ;
	l_adl_rec.award_id               := p_award_id;
	l_adl_rec.raw_cost		 := 0;
	l_adl_rec.last_update_date    	 := SYSDATE;
	l_adl_rec.creation_date      	 := SYSDATE;
	l_adl_rec.last_updated_by     	 := fnd_global.user_id;
	l_adl_rec.created_by         	 := fnd_global.user_id;
	l_adl_rec.last_update_login   	 := 0;
	l_adl_rec.po_distribution_id     := p_distribution_id ;
	l_adl_rec.request_id             := p_distribution_num ;

	gms_awards_dist_pkg.create_adls(l_adl_rec);

    	x_msg_count     := l_msg_count ;
    	x_msg_data      := l_msg_data ;
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
    		fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
   END create_pdoi_adls ;
   --
   -- GET_AWARD_NUMBER : the function overloading was created to get the award number in a
   -- SQL.
   --
   FUNCTION GET_AWARD_NUMBER( p_award_set_id IN NUMBER)
      return varchar2 is
      l_award_number gms_awards_all.award_number%TYPE ;
   BEGIN
      IF p_award_set_id is NULL THEN
         return NULL ;
      END IF ;

      select awd.award_number
        into l_award_number
        from gms_awards_all awd,
             gms_award_distributions adl
       where adl.award_set_id = p_award_set_id
         and adl.award_id     = awd.award_id
         and adl.adl_line_num = 1 ;

      return l_award_number ;

   END get_award_number ;

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
          x_award_set_id_out   out nocopy number ) is

      l_adl_rec        gms_award_distributions%ROWTYPE	;
      l_award_id       gms_awards_all.award_id%TYPE ;
      l_msg_count      number ;
      l_msg_data       varchar2(2000) ;
      l_return_status  varchar2(1)  ;
      l_api_name       varchar2(50) :=  'CREATE_PO_ADL' ;
      l_gms_enabled    boolean ;

    BEGIN
    	-- Standrad call to check API compatibility.
    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
    					    G_pkg_name ) THEN
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

        l_gms_enabled := gms_install.enabled ;

        IF not l_gms_enabled OR p_award_number is NULL then
           return ;
        END IF ;

        select award_id
          into l_award_id
          from gms_awards_all
         where award_number = p_award_number ;

        l_adl_rec.last_update_date  := sysdate ;
	l_adl_rec.last_updated_by   := nvl(fnd_global.user_id,0) ;
	l_adl_rec.created_by	     := nvl(fnd_global.user_id,0) ;
	l_adl_rec.creation_date     := SYSDATE;
	l_adl_rec.last_update_login := 0;
        l_adl_rec.award_set_id      := get_new_award_set_id;
        x_award_set_id_out           := l_adl_rec.award_set_id;
        l_adl_rec.adl_line_num      := 1 ;
        l_adl_rec.distribution_value:= 100 ;
        l_adl_rec.document_type     := 'PO' ;
        l_adl_rec.project_id        := p_project_id ;
        l_adl_rec.task_id           := p_task_id ;
        l_adl_rec.award_id          := l_award_id ;
        l_adl_rec.adl_status        := 'A' ;
        l_adl_rec.fc_status         := 'N' ;
        l_adl_rec.line_type         := 'R' ;
        l_adl_rec.capitalized_flag  := 'N' ;
        l_adl_rec.capitalizable_flag:= NULL ;
        l_adl_rec.po_distribution_id:= p_po_distribution_id ;
        gms_awards_dist_pkg.create_adls(l_adl_rec) ;

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
      		   fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
    END CREATE_PO_ADL ;

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
          x_award_set_id_out    out nocopy number )  is

      l_adl_rec	         gms_award_distributions%ROWTYPE	;
      l_create_flag      varchar2(1) ;
      l_update_flag      varchar2(1) ;
      l_award_set_id_out number ;
      l_award_id         gms_awards_all.award_id%TYPE ;

      l_msg_count        number ;
      l_msg_data         varchar2(2000) ;
      l_return_status    varchar2(1)  ;
      l_api_name         varchar2(50) :=  'UPDATE_PO_ADL' ;
      l_gms_enabled      boolean ;

      cursor C_ADL is
       select   award_set_id,
                adl_line_num,
                funding_pattern_id,
                distribution_value,
                document_type,
                project_id,
                task_id,
                award_id,
                ind_compiled_set_id,
                gl_date,
                request_id,
                line_num_reversed,
                resource_list_member_id,
                output_tax_classification_code,
                output_tax_exempt_flag,
                output_tax_exempt_reason_code,
                output_tax_exempt_number,
                adl_status,
                fc_status,
                line_type,
                capitalized_flag,
                capitalizable_flag,
                reversed_flag,
                revenue_distributed_flag,
                billed_flag,
                bill_hold_flag,
                distribution_id,
                po_distribution_id,
                invoice_distribution_id,
                invoice_id,
                distribution_line_number,
                burdenable_raw_cost,
                cost_distributed_flag,
                last_update_date,
                last_updated_by,
                created_by,
                creation_date,
                last_update_login,
                billable_flag
        from gms_award_distributions
       where award_set_id       = p_award_set_id_in
         and document_type      = 'PO'
         and po_distribution_id = p_po_distribution_id
         and adl_line_num       = 1 ;

    BEGIN
    	-- Standrad call to check API compatibility.
    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
    					    G_pkg_name ) THEN
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

       l_gms_enabled := gms_install.enabled ;

       IF not l_gms_enabled then
	       return ;
       END IF ;

      l_create_flag := 'N' ;
      l_update_flag := 'Y' ;

      IF p_award_set_id_in is not NULL THEN
        open c_adl ;
        fetch c_adl into
               l_adl_rec.award_set_id,
               l_adl_rec.adl_line_num,
               l_adl_rec.funding_pattern_id,
               l_adl_rec.distribution_value,
               l_adl_rec.document_type,
               l_adl_rec.project_id,
               l_adl_rec.task_id,
               l_adl_rec.award_id,
               l_adl_rec.ind_compiled_set_id,
               l_adl_rec.gl_date,
               l_adl_rec.request_id,
               l_adl_rec.line_num_reversed,
               l_adl_rec.resource_list_member_id,
               l_adl_rec.output_tax_classification_code,
               l_adl_rec.output_tax_exempt_flag,
               l_adl_rec.output_tax_exempt_reason_code,
               l_adl_rec.output_tax_exempt_number,
               l_adl_rec.adl_status,
               l_adl_rec.fc_status,
               l_adl_rec.line_type,
               l_adl_rec.capitalized_flag,
               l_adl_rec.capitalizable_flag,
               l_adl_rec.reversed_flag,
               l_adl_rec.revenue_distributed_flag,
               l_adl_rec.billed_flag,
               l_adl_rec.bill_hold_flag,
               l_adl_rec.distribution_id,
               l_adl_rec.po_distribution_id,
               l_adl_rec.invoice_distribution_id,
               l_adl_rec.invoice_id,
               l_adl_rec.distribution_line_number,
               l_adl_rec.burdenable_raw_cost,
               l_adl_rec.cost_distributed_flag,
               l_adl_rec.last_update_date,
               l_adl_rec.last_updated_by,
               l_adl_rec.created_by,
               l_adl_rec.creation_date,
               l_adl_rec.last_update_login,
               l_adl_rec.billable_flag	;
        close c_adl ;
      END IF ;

      IF NVL(l_adl_rec.po_distribution_id,0) <> p_po_distribution_id THEN
         l_create_flag := 'Y' ;
         l_update_flag := 'N' ;
      END IF ;

      If p_award_number is NULL and l_update_flag = 'Y' THEN
         DELETE_PO_ADL
            ( p_api_version     => p_api_version,
              p_commit          => p_commit,
              p_init_msg_list   => p_init_msg_list,
              p_validation_level=> p_validation_level,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data,
              x_return_status   => x_return_status,
              p_award_set_id_in => p_award_set_id_in,
              p_po_distribution_id => p_po_distribution_id ) ;

              l_award_set_id_out := NULL ;

      ELSIF p_award_number is not NULL and l_create_flag = 'Y' THEN
         CREATE_PO_ADL
            ( p_api_version     => p_api_version,
              p_commit          => p_commit,
              p_init_msg_list   => p_init_msg_list,
              p_validation_level=> p_validation_level,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data,
              x_return_status   => x_return_status,
              p_project_id      => p_project_id,
              p_task_id         => p_task_id,
              p_award_number    => p_award_number,
              p_po_distribution_id => p_po_distribution_id,
              x_award_set_id_out => l_award_set_id_out ) ;
      ELSIF p_award_number is not NULL and l_update_flag = 'Y' THEN

            l_adl_rec.project_id := p_project_id ;
            l_adl_rec.task_id    := p_task_id;
            l_award_set_id_out   := p_award_set_id_in ;

            select award_id
              into l_award_id
              from gms_awards_all
             where award_number = p_award_number ;

            l_adl_rec.award_id         := l_award_id ;
            l_adl_rec.last_update_date := sysdate ;
	    l_adl_rec.last_updated_by  := nvl(fnd_global.user_id,0) ;

            gms_awards_dist_pkg.update_adls(l_adl_rec) ;

      END IF ;
      x_award_set_id_out := l_award_set_id_out ;

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
      		   fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
    END  MAINTAIN_PO_ADL ;

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
          p_po_distribution_id in        number ) IS

      l_msg_count        number ;
      l_msg_data         varchar2(2000) ;
      l_return_status    varchar2(1)  ;
      l_api_name         varchar2(50) :=  'DELETE_PO_ADL' ;
      l_gms_enabled      boolean ;
    BEGIN
    	-- Standrad call to check API compatibility.
    	IF NOT FND_API.Compatible_API_Call( G_api_version,
    					    p_api_version,
    					    l_api_name,
    					    G_pkg_name ) THEN
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

       l_gms_enabled := gms_install.enabled ;

       IF not l_gms_enabled or p_award_set_id_in is NULL then
	       return ;
       END IF ;

       IF p_po_distribution_id is NULL THEN

          delete from gms_award_distributions
           where award_set_id       = p_award_set_id_in
             and document_type      = 'PO'
             and adl_line_num       = 1
             and po_distribution_id is NULL ;
       ELSE
          delete from gms_award_distributions
           where award_set_id       = p_award_set_id_in
             and document_type      = 'PO'
             and adl_line_num       = 1
             and po_distribution_id = p_po_distribution_id ;
       END IF ;

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
      	       fnd_msg_pub.add_exc_msg( G_pkg_name, l_api_name ) ;
    	    END IF ;
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => x_msg_count ,
    					p_data    => x_msg_data ) ;
   END DELETE_PO_ADL ;

	FUNCTION  IS_SPONSORED_PROJECT( p_project_id in NUMBER ) return varchar2
	is
		cursor C_spon_project is
			select pt.sponsored_flag
			  from pa_projects_all b,
			       gms_project_types pt
			 where b.project_id 	= p_project_id
			   and b.project_type	= pt.project_type
			   and pt.sponsored_flag = 'Y' ;

		x_return  varchar2(1) ;
		x_flag	  varchar2(1) ;
	BEGIN

		x_return := 'N' ;

		open C_spon_project ;
		fetch C_spon_project into x_flag ;
		close C_spon_project ;

		IF nvl(x_flag, 'N') = 'Y' THEN
		   x_return := 'Y' ;
		END IF ;

		return x_return ;

	END IS_SPONSORED_PROJECT ;

END GMS_PO_API_GRP ;


/
