--------------------------------------------------------
--  DDL for Package Body GMS_POR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_POR_API" as
--$Header: gmspor1b.pls 120.1 2005/09/09 16:33:16 appldev ship $


	-- =============================================================
	-- Following API returns award number based on the award_id,
	-- award set id or req_distribution_id.
	-- This is used to display award number in Billing Region.
	-- =============================================================
	FUNCTION get_award_number ( X_award_set_id  		IN NUMBER,
				    X_award_id			IN NUMBER,
				    X_req_distribution_id 	IN NUMBER)
	return VARCHAR2 IS

	cursor c_award_number is
		select award_number
		  from gms_awards_all
		 where award_id = X_award_id ;

	cursor c_adl_award is
		select a.award_number
		  from gms_awards_all a,
		       gms_award_distributions adl
		 where adl.award_set_id	= X_award_set_id
		   and adl_status	= 'A'
		   and adl_line_num	= 1
		   and adl.award_id	= a.award_id ;

	cursor c_req_award is
		select a.award_number
		  from gms_awards_all a,
		       gms_award_distributions adl ,
		       po_req_distributions_all req
		 where adl.award_set_id	= req.award_id
		   and req.distribution_id = X_req_distribution_id
		   and adl_status	= 'A'
		   and adl_line_num	= 1
		   and adl.award_id	= a.award_id ;

       CURSOR  c_check_award IS
               SELECT default_dist_award_number
               FROM   gms_implementations
               WHERE  enabled ='Y'
		 and award_distribution_option = 'Y'
                 and default_dist_award_id = X_award_id ;

	l_award_number	varchar2(15) ;
	BEGIN
		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================
		IF not gms_install.enabled then
			return l_award_number;
		END IF ;

		IF X_award_id is not NULL  THEN

			open c_award_number ;
			fetch c_award_number into l_award_number ;

			IF c_award_number%NOTFOUND THEN

				open c_check_award ;
				fetch c_check_award into l_award_number ;

				IF c_check_award%NOTFOUND THEN
					close c_check_award ;
					raise no_data_found ;
				END IF ;

				CLOSE c_check_award ;
			END IF ;
			close c_award_number ;

		ELSIF X_award_set_id is not NULL THEN

			open c_adl_award ;
			fetch c_adl_award into l_award_number ;

			IF c_adl_award%NOTFOUND THEN
				close c_adl_award ;
				raise no_data_found ;
			END IF ;
			close c_adl_award ;

		ELSIF X_req_distribution_id is not NULL  THEN

			open c_req_award ;
			fetch c_req_award into l_award_number ;

			IF c_req_award%NOTFOUND THEN
				close c_req_award ;
				raise no_data_found ;
			END IF ;
			close c_req_award ;

		END IF ;

		return(l_award_number) ;
	END get_award_number ;

	-- =============================================================
	-- Following API returns award ID based on the award_number,
	-- award set id or req_distribution_id.
	-- This is used to determine award_id .
	-- =============================================================

	FUNCTION get_award_ID ( X_award_set_id  	IN NUMBER,
			    	X_award_number		IN VARCHAR2,
			    	X_req_distribution_id 	IN NUMBER)
	return NUMBER IS

	cursor c_award_id is
		select award_id
		  from gms_awards_all
		 where award_number = X_award_number ;

	cursor c_adl_award is
		select adl.award_id
		  from gms_award_distributions adl
		 where adl.award_set_id	= X_award_set_id
		   and adl_status	= 'A'
		   and adl_line_num	= 1 ;

	cursor c_req_award is
		select adl.award_id
		  from gms_award_distributions adl ,
		       po_req_distributions_all req
		 where adl.award_set_id	= req.award_id
		   and req.distribution_id = X_req_distribution_id
		   and adl_status	= 'A'
		   and adl.adl_line_num	= 1 ;

       CURSOR  c_check_award IS
               SELECT default_dist_award_id
               FROM   gms_implementations
               WHERE  enabled ='Y'
		 and award_distribution_option = 'Y'
                 and default_dist_award_number = X_award_number ;

	l_award_id number ;
	begin
		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================
		IF not gms_install.enabled then
			return l_award_id;
		END IF ;


		IF X_award_number is not NULL  THEN

			open c_award_id ;
			fetch c_award_id into l_award_id ;

			IF c_award_id%NOTFOUND THEN
				-- Check is default award is entered.
				-- return default award id in this case.
				-- BUG identified by IP.
				-- ---------------------------------------
				open c_check_award ;
				fetch c_check_award into l_award_id ;

				IF c_check_award%NOTFOUND THEN
					close c_check_award ;
					raise no_data_found ;
				END IF ;

				CLOSE c_check_award ;

			END IF ;
			close c_award_id ;

		ELSIF X_award_set_id is not NULL  THEN

			open c_adl_award ;
			fetch c_adl_award into l_award_id ;

			IF c_adl_award%NOTFOUND THEN
				close c_adl_award ;
				raise no_data_found ;
			END IF ;
			close c_adl_award ;

		ELSIF X_req_distribution_id is not NULL THEN

			open c_req_award ;
			fetch c_req_award into l_award_id ;

			IF c_req_award%NOTFOUND THEN
				close c_req_award ;
				raise no_data_found ;
			END IF ;
			close c_req_award ;

		END IF ;


		return (l_award_id) ;
	end get_award_ID ;

	-- ===================================================================
	-- Following program unit is used to determine sponsored project.
	-- ===================================================================
	FUNCTION  IS_SPONSORED_PROJECT( x_project_id in NUMBER ) return BOOLEAN
	is
		cursor C_spon_project is
			select pt.sponsored_flag
			  from pa_projects_all b,
			       gms_project_types pt
			 where b.project_id 	= X_project_id
			   and b.project_type	= pt.project_type
			   and pt.sponsored_flag = 'Y' ;

		x_return  BOOLEAN ;
		x_flag	  varchar2(1) ;
	BEGIN

		x_return := FALSE ;

		open C_spon_project ;
		fetch C_spon_project into x_flag ;
		close C_spon_project ;

		IF nvl(x_flag, 'N') = 'Y' THEN
		   x_return := TRUE ;
		END IF ;

		return x_return ;

	END IS_SPONSORED_PROJECT ;

	-- =========================================================
	-- Validate award does the standard grants validations
	-- program unit make sure that award is entered for
	-- sponsored projects and expenditure item date
	-- validations are done.
	-- Grants common routine for standard validations is
	-- called here.
	-- =========================================================
	PROCEDURE validate_award ( X_project_id		IN NUMBER,
				   X_task_id		IN NUMBER,
				   X_award_id		IN NUMBER,
				   X_award_number	IN VARCHAR2,
				   X_expenditure_type	IN VARCHAR2,
				   X_expenditure_item_date IN DATE,
				   X_calling_module	IN VARCHAR2,
                                   X_source_type_code   IN VARCHAR2,--Bug-2557041
				   X_status		IN OUT NOCOPY VARCHAR2,
				   X_err_msg		OUT NOCOPY VARCHAR2 ) is

	l_project_type_class_code 	varchar2(30);
	l_row_found		 	varchar2(1);
	l_award_id			NUMBER ;
	l_dummy				NUMBER ;
	l_award_dist_option		varchar2(1) ;
	l_award_number			varchar2(15) ;
	l_status			varchar2(1) ;

       CURSOR  c_check_award IS
               SELECT default_dist_award_id,
		      award_distribution_option,
		      default_dist_award_number
               FROM   gms_implementations
               WHERE  enabled ='Y' ;

	cursor valid_award_csr is
	select 	'Y'
	from 	dual
	where exists
		(select 1
		from gms_awards
		where award_number = X_award_number
		and   nvl(award_id,0) = nvl(l_award_id,0));
        --Bug 2579915
        Cursor  valid_project_type_class is
                select project_type_class_code
                from pa_project_types a,
                     pa_projects_all b
                where a.project_type = b.project_type
                and   b.project_id = X_project_id;


	BEGIN
		l_status := X_status ;
		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================
		IF not gms_install.enabled then
			return ;
		END IF ;

		open c_check_award ;
		fetch c_check_award into l_dummy ,
		      l_award_dist_option , l_award_number ;
		close c_check_award ;

		IF NVL(l_award_number, '-X')    = x_award_number and
		   NVL(l_award_dist_option,'N') = 'Y' then
		   RETURN ;
		END IF ;


		-- We don't need to continue .
		-- entered award is dummy award.
		--IF X_award_id < 0 and THEN
		 --  RETURN ;
		--end if ;


		-- ============================================
		-- No need to proceed if project/award details
		-- are null.
		-- ============================================
		IF x_project_id	is NULL AND
		   x_award_id	is NULL AND
		   x_award_number is NULL THEN

		   return ;
		END IF ;


		-- =======================================================
		-- List of validations done here
		-- 1. Check for contract project. contract project shouldn't
		--    entered if grants is enabled.
		-- 2. Nonsponsored project having award should fail.
		-- 3. Invalid award should stop here.
		-- 4. Populate award id if required.
		--    Award id passed null and award_number is not null.
		-- 5. Sponsored project missing award should error out.
		-- 6. Check expenditure type belongs to allowable exp's.
		-- 7. Call gms standard validations defined in
		--    gms_transaction_pub.
		-- ================================================================

		l_award_id := X_award_id ;

		-- 1. Check for contract project. contract project shouldn't
		--    entered if grants is enabled.

		IF X_project_id is not NULL THEN
                    OPEN  valid_project_type_class;
                    FETCH valid_project_type_class INTO l_project_type_class_code;
                    CLOSE valid_project_type_class;
		END IF ;

		if l_project_type_class_code = 'CONTRACT' then

			fnd_message.set_name('GMS','GMS_IP_INVALID_PROJ_TYPE');

			l_status :=  'E';
			X_err_msg :=  fnd_message.get;
			X_status :=  'E';

			return;
		end if;

		IF is_sponsored_project (X_project_id) THEN

                   --==============================================================
                   -- Bug-2557041
                   -- Do not proceed if grants is  enabled and Requisition type is
                   -- internal
                   --==============================================================
                   -- 4555829 support internal requisitions.

                   IF nvl(x_source_type_code,'INVENTORY') = 'INVENTORY'  and
                      gms_client_extn_po.allow_internal_req = 'N' THEN
			fnd_message.set_name('GMS','GMS_IP_INVALID_REQ_TYPE');
			l_status :=  'E';
			X_err_msg :=  fnd_message.get;
			x_status :=  'E';
			return;
                   END IF;

		   -- 5. Sponsored project missing award should error out.
		   IF X_award_number is NULL then
			fnd_message.set_name('GMS','GMS_AWARD_REQUIRED');
			X_err_msg :=  fnd_message.get;
			l_status :=  'E';
			x_status :=  'E';
			return;
		   END IF ;

		ELSE

		   -- 2. Nonsponsored project having award should fail.
		   IF X_award_number is NOT NULL then
			fnd_message.set_name('GMS','GMS_AWARD_NOT_ALLOWED');
			X_err_msg :=  fnd_message.get;
			X_status :=  'E';
			L_status :=  'E';
			return;
                   ELSE --Added to fix bug 2579915
                       return;
		   END IF ;

		END IF ;


		-- 3. Populate award id if required.
		--    Award id passed null and award_number is not null.

		l_award_id 	:= X_award_id ;

		if X_award_id is NULL and
		   X_award_number is not NULL then
		   -- ===============================================================
		   -- BUG : 2714080 ( FPISTIP: IP57: ERROR MESSAGE IS NOT PROPER )
		   -- ===============================================================

		   BEGIN
			select 	award_id
			into	l_award_id
			from 	gms_awards
			where 	award_number = X_award_number;
		   EXCEPTION
			When no_data_found then
				l_award_id := 0 ;

		   END ;


		end if;

		-- 4. Invalid award should stop here.

		open valid_award_csr;
		fetch valid_award_csr into l_row_found;
		close valid_award_csr;

		if NVL(l_row_found,'N') <> 'Y' then

			fnd_message.set_name('GMS','GMS_INVALID_AWARD');

			X_err_msg :=  fnd_message.get;
			X_status :=  'E';
			L_status :=  'E';

			return;

		end if;

		-- 7. Call gms standard validations defined in
		--    gms_transaction_pub.

		gms_transactions_pub.validate_transaction(p_project_id => X_project_id,
							  p_task_id => X_task_id,
							  p_award_id => l_award_id,
							  p_expenditure_type => X_expenditure_type,
							  p_expenditure_item_date => X_expenditure_item_date,
							  p_calling_module => 'GMS-IP',
							  p_outcome => X_err_msg );

		if X_err_msg is NOT NULL then

			X_status := 'E';
			L_status := 'E';

		end if;

		x_status := l_status ;

		return ;

	END validate_award ;
        --BUG 3295360  add Procedure to provide  backward compatibility through overloading
	PROCEDURE validate_award ( X_project_id		IN NUMBER,
				   X_task_id		IN NUMBER,
				   X_award_id		IN NUMBER,
				   X_award_number	IN VARCHAR2,
				   X_expenditure_type	IN VARCHAR2,
				   X_expenditure_item_date IN DATE,
				   X_calling_module	IN VARCHAR2,
				   X_status		IN OUT NOCOPY VARCHAR2,
       				   X_err_msg		OUT NOCOPY VARCHAR2 ) IS
        BEGIN
	       gms_por_api.validate_award( X_project_id            => x_project_id,
                  X_task_id               => x_task_id,
                  X_award_id              => x_award_id,
                  X_award_number          => x_award_number,
                  X_expenditure_type      => X_expenditure_type,
                  X_expenditure_item_date => X_expenditure_item_date,
                  X_calling_module        => x_calling_module,
                  X_source_type_code      => 'GMS-IP',
                  X_status                => X_status,
                  X_err_msg               => X_err_msg );
        END Validate_award ;

	-- ==============================================================
	-- ADL must be present for account generator. Event based
	-- processing is done to create or remove adls.
	-- ==============================================================

	PROCEDURE account_generator_ADL ( X_project_id		IN NUMBER,
					  X_task_id		IN NUMBER,
					  X_award_id		IN NUMBER,
					  X_event		IN VARCHAR2,
					  X_award_set_id	IN OUT NOCOPY NUMBER,
					  X_status		IN OUT NOCOPY varchar2 ) is

		x_adl_rec    		gms_award_distributions%ROWTYPE;
		l_sponsored_flag	varchar2(1) ;
		l_award_set_id		number ;
		l_status		varchar2(1) ;

		cursor C_spon_project is
			select pt.sponsored_flag
			  from pa_projects_all b,
			       gms_project_types pt
			 where b.project_id 	= X_project_id
			   and b.project_type	= pt.project_type
			   and pt.sponsored_flag = 'Y' ;

	BEGIN

		l_status	:= X_status ;
		l_award_set_id  := X_award_set_id ;

		--db_pack_message('Account Gen :'||X_event||' asid :'||NVL(X_award_set_id,0)) ;
		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================

		IF not gms_install.enabled then
			return ;
		END IF ;

		IF X_event = 'REMOVE' THEN

			delete from gms_award_distributions
			 where award_set_id	= X_award_set_id ;

			RETURN ;
		END IF ;

		IF NVL(X_event,'NULL')  <> 'CREATE' THEN
			return ;
		END IF ;

		open C_spon_project ;
		fetch C_spon_project into l_sponsored_flag ;
		close C_spon_project ;

		IF NVL(l_sponsored_flag,'N') <> 'Y' THEN
		   return ;
		END IF ;

		x_adl_rec.expenditure_item_id	 := NULL ;
		x_adl_rec.project_id 		 := X_project_id;
		x_adl_rec.task_id   		 := X_task_id;
		x_adl_rec.cost_distributed_flag	 := 'N';
		x_adl_rec.cdl_line_num           := NULL;
		x_adl_rec.adl_line_num           := 1;
		x_adl_rec.distribution_value     := 100 ;
		x_adl_rec.line_type              := 'R';
		x_adl_rec.adl_status             := 'A';
		x_adl_rec.document_type          := 'REQ';
		x_adl_rec.billed_flag            := 'N';
		x_adl_rec.bill_hold_flag         := NULL ;
		x_adl_rec.award_set_id           := gms_awards_dist_pkg.get_award_set_id;
		x_adl_rec.award_id               := X_award_id;
		x_adl_rec.raw_cost		 := 0;
		x_adl_rec.last_update_date    	 := SYSDATE;
		x_adl_rec.creation_date      	 := SYSDATE;
		x_adl_rec.last_updated_by     	 := 0;
		x_adl_rec.created_by         	 := 0;
		x_adl_rec.last_update_login   	 := 0;

		gms_awards_dist_pkg.create_adls(X_adl_rec);

		X_award_set_id 			 := x_adl_rec.award_set_id ;
		l_award_set_id 			 := x_adl_rec.award_set_id ;
		--db_pack_message('Account Gen : awsid '||X_event||' asid :'||NVL(X_award_set_id,0)) ;

	EXCEPTION
		When others then
			X_status	:= SQLCODE ;
			raise ;
	END account_generator_ADL ;

        -- Start
	-- 3068454 ( CHANGE REQUIRED IN GMS_POR_API.WHEN_UPDATE/INSERT_LINE TO WORK
	-- WITH OA GUIDELINE )
	--
        PROCEDURE get_req_dist_AwardSetID ( X_distribution_id   IN NUMBER,
					    X_award_set_id      OUT NOCOPY NUMBER,
					    X_status            IN OUT NOCOPY varchar2 ) is
		l_award_set_id	NUMBER ;

		Cursor c_award_set_id is
		select award_id
		  from po_req_distributions_all
		 where distribution_id	= X_distribution_id ;

        BEGIN
		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================
		IF not gms_install.enabled then
		   return ;
		END IF ;

		open c_award_set_id ;
		fetch c_award_set_id into l_award_set_id ;
		close c_award_set_id ;

		X_award_set_id := l_award_set_id ;
		X_status       := 'S' ;

	EXCEPTION
	   When Others THEN
		X_status := SQLCODE ;
		RAISE ;
	END get_req_dist_AwardSetID;
        --
	-- 3068454 ( CHANGE REQUIRED IN GMS_POR_API.WHEN_UPDATE/INSERT_LINE TO WORK
	-- WITH OA GUIDELINE )
	-- END.

	-- =============================================================
	-- Create award distribution lines when REQ DISTRIBUTION LINE
	-- is created for a sponsored projects. This also tieback
	-- ADL with REQ.
	-- =============================================================
	PROCEDURE when_insert_line (	X_distribution_id	IN NUMBER,
					X_project_id		IN NUMBER,
				   	X_task_id		IN NUMBER,
				   	X_award_id		IN NUMBER,
				   	X_expenditure_type	IN VARCHAR2,
				   	X_expenditure_item_date IN DATE,
					--X_raw_cost		IN NUMBER,
					X_award_set_id		OUT NOCOPY NUMBER,
					X_status		IN OUT NOCOPY varchar2 ) is

		x_adl_rec    gms_award_distributions%ROWTYPE;
	BEGIN
		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================
		IF not gms_install.enabled then
			return ;
		END IF ;

		IF NOT IS_SPONSORED_PROJECT( X_project_id ) THEN
			return ;
		END IF ;

		x_adl_rec.expenditure_item_id	 := NULL ;
		x_adl_rec.project_id 		 := X_project_id;
		x_adl_rec.task_id   		 := X_task_id;
		x_adl_rec.cost_distributed_flag	 := 'N';
		x_adl_rec.cdl_line_num           := NULL;
		x_adl_rec.adl_line_num           := 1;
		x_adl_rec.distribution_value     := 100 ;
		x_adl_rec.line_type              := 'R';
		x_adl_rec.adl_status             := 'A';
		x_adl_rec.document_type          := 'REQ';
		x_adl_rec.billed_flag            := 'N';
		x_adl_rec.bill_hold_flag         := NULL ;
		x_adl_rec.award_set_id           := gms_awards_dist_pkg.get_award_set_id;
		x_adl_rec.award_id               := X_award_id;
		x_adl_rec.raw_cost		 := NULL;
		x_adl_rec.last_update_date    	 := SYSDATE;
		x_adl_rec.creation_date      	 := SYSDATE;
		x_adl_rec.last_updated_by     	 := 0;
		x_adl_rec.created_by         	 := 0;
		x_adl_rec.last_update_login   	 := 0;
		X_adl_rec.distribution_id	 := X_distribution_id ;
		--db_pack_message('When Insert Line Test :'||X_distribution_id) ;


		gms_awards_dist_pkg.create_adls(X_adl_rec);

		UPDATE PO_REQ_DISTRIBUTIONS_ALL
		   SET award_id  = x_adl_rec.award_set_id
		 where distribution_id	= X_distribution_id ;

                x_award_set_id := x_adl_rec.award_set_id ;
		return ;
	END when_insert_line ;

        --  Start...
	-- 3068454 ( CHANGE REQUIRED IN GMS_POR_API.WHEN_UPDATE/INSERT_LINE TO WORK
	-- WITH OA GUIDELINE )
	--
	-- When_update_line overloading
	-- x_award_set_id was added.
	--
	PROCEDURE when_update_line (	X_distribution_id	IN NUMBER,
					X_project_id		IN NUMBER,
				   	X_task_id		IN NUMBER,
				   	X_award_id		IN NUMBER,
				   	X_expenditure_type	IN VARCHAR2,
				   	X_expenditure_item_date IN DATE,
					X_award_set_id          OUT NOCOPY NUMBER,
					X_status		IN OUT NOCOPY varchar2 ) is
	   l_award_set_id NUMBER ;

	   Cursor c_award_set_id is
	    select award_id
	      from po_req_distributions_all
	     where distribution_id	= X_distribution_id ;

        BEGIN

	     when_update_line ( X_distribution_id,
				X_project_id,
				X_task_id,
				X_award_id,
				X_expenditure_type,
				X_expenditure_item_date,
				X_status ) ;

		open c_award_set_id ;
		fetch c_award_set_id into l_award_set_id ;
		close c_award_set_id ;

		X_award_set_id := l_award_set_id ;

	EXCEPTION
		WHEN OTHERS THEN
			X_status := SQLCODE ;
			RAISE ;
	END when_update_line ;

        --
	-- 3068454 ( CHANGE REQUIRED IN GMS_POR_API.WHEN_UPDATE/INSERT_LINE TO WORK
	-- WITH OA GUIDELINE )
	-- END.............

	-- ================================================================
	-- following program unit control DML operations or Poject/task
	-- and award. ADLS are updated for change in project/task or award.
	-- Adls are also removed for project changed from sponsored to
	-- non sponsored.
	-- ================================================================

	PROCEDURE when_update_line (	X_distribution_id	IN NUMBER,
					X_project_id		IN NUMBER,
				   	X_task_id		IN NUMBER,
				   	X_award_id		IN NUMBER,
				   	X_expenditure_type	IN VARCHAR2,
				   	X_expenditure_item_date IN DATE,
					--X_raw_cost		IN NUMBER,
					X_status		IN OUT NOCOPY varchar2 ) is

		x_award_set_id	NUMBER ;

		Cursor c_award_set_id is
			select award_id
			  from po_req_distributions_all
			 where distribution_id	= X_distribution_id ;

	BEGIN
		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================
		IF not gms_install.enabled then
			return ;
		END IF ;

		open c_award_set_id ;
		fetch c_award_set_id into x_award_set_id ;
		close c_award_set_id ;

		--db_pack_message('When Update Line :'||NVL(X_award_set_id,0)) ;

		IF NVL(x_award_set_id, 0) = 0 THEN
	   		when_insert_line (	X_distribution_id,
						X_project_id		,
				   		X_task_id		,
				   		X_award_id		,
				   		X_expenditure_type	,
				   		X_expenditure_item_date ,
						--X_raw_cost		,
						X_award_set_id		,
						X_status		) ;
			RETURN ;

		ELSE
			IF NOT IS_SPONSORED_PROJECT( X_project_id ) THEN

				delete from gms_award_distributions
				 where award_set_id = x_award_set_id
				   and adl_status   = 'A' ;

				UPDATE PO_REQ_DISTRIBUTIONS_ALL
				   SET award_id  = NULL
				 where distribution_id	= X_distribution_id ;

				RETURN ;
			END IF ;

			update gms_award_distributions
			   set project_id	= X_project_id,
			       task_id		= X_task_id,
			       award_id		= X_award_id
			 where award_set_id = x_award_set_id
			   and adl_line_num = 1
			   and document_type= 'REQ'
			   and adl_status   = 'A' ;

			IF SQL%NOTFOUND THEN
				raise no_data_found ;
			END IF ;


		END IF ;
		return ;
	EXCEPTION
		WHEN OTHERS THEN
			X_status := SQLCODE ;
			RAISE ;
	END when_update_line ;

	-- =================================================================
	-- Delete unwanted award distribution lines here.
	-- =================================================================

	PROCEDURE when_delete_line (	X_distribution_id	IN NUMBER,
					X_status		IN OUT NOCOPY varchar2 ) is

		x_award_set_id	NUMBER ;

		Cursor c_award_set_id is
			select award_id
			  from po_req_distributions_all
			 where distribution_id	= X_distribution_id ;

	BEGIN
		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================
		IF not gms_install.enabled then
			return ;
		END IF ;

		open c_award_set_id ;
		fetch c_award_set_id into x_award_set_id ;
		close c_award_set_id ;

		IF NVL(x_award_set_id, 0) > 0 THEN

			delete from gms_award_distributions
			 where award_set_id = x_award_set_id
			   and adl_status   = 'A' ;

		END IF ;
		return ;
	END when_delete_line ;

       --
       -- Start : 3103564
       --         NEW DELETE API NEEDED FOR DELETING AN AWARD DISTRIBUTION LINE
       --
       -- Start of comments
       --	API name 	: delete_adl
       --	Type		: Public
       --	Pre-reqs	: None.
       --	Function	: Deletes a record from gms_award_distributions
       --			  table.
       --	Parameters	:
       --	IN		: p_award_set_id          IN NUMBER	Required
       --			  .
       --			  .
       --       OUT             : x_status               OUT Varchar2
       --                         values are 'S', 'E', 'U'
       --                         fnd_api.G_RET_STS_SUCCESS
       --                         fnd_api.G_RET_STS_ERROR
       --                         fnd_api.G_RET_STS_UNEXP_ERROR
       -- End of comments

       PROCEDURE delete_adl ( p_award_set_id 	IN NUMBER,
                              x_status          OUT NOCOPY varchar2,
                              x_err_msg         OUT NOCOPY varchar2 ) is
         l_status  varchar2(1) ;
	 l_err_msg varchar2(4000) ;
       BEGIN
	   -- ==============================================================
	   -- Do not proceed if grants is not enabled for an implementation
	   -- Org.
	   -- ==============================================================
	   l_status := FND_API.G_RET_STS_SUCCESS ;
	   l_err_msg:= NULL ;
	   x_status := l_status ;

	   IF not gms_install.enabled then
	      return ;
	   END IF ;

	   IF NVL(p_award_set_id, 0) > 0 THEN

	      delete from gms_award_distributions
	       where award_set_id = p_award_set_id
	         and adl_status   = 'A' ;

	      IF SQL%NOTFOUND then
		 fnd_message.set_name('GMS','GMS_INVALID_AWARD');

		 l_err_msg :=  fnd_message.get;
		 l_status  := FND_API.G_RET_STS_ERROR ;
	      END IF ;
	   END IF ;

	   x_err_msg:= l_err_msg ;
	   x_status := l_status ;
       EXCEPTION
	   When Others THEN
                l_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		l_err_msg:= SQLERRM ;

		x_err_msg:= l_err_msg ;
		x_status := l_status ;
       END delete_adl ;
       --
       -- NEW DELETE API NEEDED FOR DELETING AN AWARD DISTRIBUTION LINE
       -- End : 3103564
       --

        --=================================================================
        -- Bug-2557041
        -- This API used by IP to determine award distribution information
        --=================================================================
        PROCEDURE get_award_dist_param (p_award_dist_option     OUT NOCOPY VARCHAR2,
                                        p_dist_award_number     OUT NOCOPY VARCHAR2,
                                        p_dist_award_id         OUT NOCOPY NUMBER )
        IS
        l_award_dist_option             gms_implementations_all.award_distribution_option%TYPE;
        l_dist_award_number             gms_implementations_all.default_dist_award_number%TYPE;
        l_dist_award_id                 gms_implementations_all.default_dist_award_id%TYPE;
        CURSOR c_default_award IS
             SELECT award_distribution_option,
                    default_dist_award_number,
                    default_dist_award_id
             FROM   gms_implementations
             WHERE  enabled ='Y';

        BEGIN
             OPEN  c_default_award;
             FETCH c_default_award
             INTO  l_award_dist_option,
                   l_dist_award_number,
                   l_dist_award_id;
             CLOSE c_default_award;

             p_award_dist_option := l_award_dist_option;
             p_dist_award_number := l_dist_award_number;
             p_dist_award_id     := l_dist_award_id;

             IF NVL(l_award_dist_option,'N') ='N' THEN
                p_award_dist_option :='N';
                p_dist_award_number :=NULL;
                p_dist_award_id     :=NULL;
             END IF;

        END get_award_dist_param;

        --=======================================================================
        -- Bug-2557041
        -- following API used to validate dummy award specific validations
        --=======================================================================
        PROCEDURE validate_dist_award(  p_project_id            IN NUMBER,
                                        p_task_id               IN NUMBER,
                                        p_award_id              IN NUMBER,
                                        p_expenditure_type      IN VARCHAR2,
                                        p_status                IN OUT NOCOPY VARCHAR2,
                                        p_err_msg_label         OUT NOCOPY VARCHAR2 )
        AS
        l_award_id      gms_awards_all.award_id%TYPE:=p_award_id;
        l_dummy         NUMBER;
        l_exp_type      gms_allowable_expenditures.expenditure_type%TYPE;
        l_msg_label     VARCHAR2(50);
        l_status        VARCHAR2(1);
        l_err_msg       VARCHAR2(2000);

       CURSOR  c_check_award IS
               SELECT default_dist_award_id
               FROM   gms_implementations
               WHERE  enabled ='Y'
               AND    award_distribution_option ='Y';

       CURSOR check_fund_pattern is
           SELECT project_id
             from gms_funding_patterns_all FPH,
                  gms_fp_distributions     FPD
            where FPH.project_id        = p_project_id
              and NVL(FPH.task_id,p_task_id) = p_task_id
              and FPH.funding_pattern_id= FPD.funding_pattern_id
              and FPH.status            = 'A'
              and NVL(FPH.retroactive_flag,'N')  = 'N' ;

       CURSOR c_exp_type IS
              SELECT gae.expenditure_type
              FROM   gms_funding_patterns gfp,
                     gms_fp_distributions gfd,
                     gms_allowable_expenditures gae,
                     pa_tasks t,
                     gms_awards ga
              WHERE  t.task_id                       =p_task_id
              AND    t.project_id                    =p_project_id
              AND    gfp.project_id                  =p_project_id
              AND    nvl(gfp.task_id,t.top_task_id ) =t.top_task_id
              AND    gfp.status                      ='A'
              AND    gfp.retroactive_flag            ='N'
              AND    gae.expenditure_type            =p_expenditure_type
              AND    gfp.funding_pattern_id          =gfd.funding_pattern_id
              AND    ga.award_id                     =gfd.award_id
              AND    ga.allowable_schedule_id        =gae.allowability_schedule_id;
        BEGIN
         l_status               := 'S';
         l_exp_type		:= p_expenditure_type;
         l_award_id		:= p_award_id;

         --===============================
         --1  Validate Dummy award is okay
         --===============================
         OPEN c_check_award;
         FETCH c_check_award INTO l_dummy;

         IF c_check_award%NOTFOUND THEN
            l_status := 'E';
            l_msg_label :='GMS_AWD_DIST_NOT_ENABLED';
         END IF;

         IF l_dummy<>l_award_id AND l_status <>'E' THEN
            l_status := 'E';
            l_msg_label:='GMS_DIST_AWD_INVALID';
         END IF;

         CLOSE c_check_award;

	 -- ====================================================
	 -- Bug : 2725486 ( Validate Funding pattern exists ) .
	 -- =====================================================
	 IF l_status <> 'E' THEN
		OPEN check_fund_pattern ;
		fetch check_fund_pattern into l_dummy ;
		IF check_fund_pattern%NOTFOUND then
			l_status :='E';
			l_msg_label :='GMS_INVALID_FUNDING_PATTERN' ;
		END IF ;
		CLOSE check_fund_pattern ;
	 END IF ;


         --===================================
         --2 Validate Expenditure Type Is Okay
         --===================================

        IF l_status <> 'E' THEN
           OPEN c_exp_type;
           FETCH c_exp_type INTO l_exp_type;
           IF c_exp_type%NOTFOUND THEN
               l_status :='E';
               l_msg_label :='GMS_EXP_TYPE_NO_PATTERN';
           END IF;
           CLOSE c_exp_type;
        END IF;

        p_status        :=l_status;

         IF l_msg_label IS NOT  NULL THEN
            P_err_msg_label :=l_msg_label;
         END IF;

        EXCEPTION
             WHEN OTHERS THEN
               p_status :='U';
               p_err_msg_label :='GMS_UNDEFINED_EXCEPTION';
               raise;
        END validate_dist_award;

        --=============================================================
        -- Bug-2557041
        -- The purpose of this API is to prepare for award distributions
        -- and kicks off award distribution engine
        --=============================================================
        PROCEDURE   distribute_award(p_doc_header_id               IN NUMBER,
                                     p_distribution_id             IN NUMBER,
                                     p_document_source             IN VARCHAR2,
                                     p_gl_encumbered_date          IN DATE,
                                     p_project_id                  IN NUMBER,
                                     p_task_id                     IN NUMBER,
                                     p_dummy_award_id              IN NUMBER,
                                     p_expenditure_type            IN VARCHAR2,
                                     p_expenditure_organization_id IN NUMBER,
                                     p_expenditure_item_date       IN DATE,
                                     p_quantity                    IN NUMBER,
                                     p_unit_price                  IN NUMBER,
                                     p_func_amount                 IN NUMBER,
                                     p_vendor_id                   IN NUMBER,
                                     p_source_type_code            IN VARCHAR2,
                                     p_award_qty_obj               OUT NOCOPY gms_obj_award,
                                     p_status                      OUT NOCOPY VARCHAR2,
                                     p_error_msg_label             OUT NOCOPY VARCHAR2 )
         AS
         l_doc_header_id    NUMBER;
         l_distribution_id  NUMBER;
         l_document_source  VARCHAR2(4);
         l_index            INTEGER;

         l_award_qty_obj    gms_obj_award;
         l_dist_status      VARCHAR2(5);
         l_status           VARCHAR2(1);
         l_msg_label        VARCHAR2(2000);
         l_recs_processed   NUMBER;
         l_recs_rejected    NUMBER;
         l_source_type_code po_requisition_lines_all.source_type_code%type;

	 CURSOR c_next_header_id IS
              SELECT gms_packet_header_id_s.NEXTVAL
              FROM   DUAL;

	 CURSOR c_next_dist_id IS
                SELECT gms_packet_dist_id_s.NEXTVAL
                FROM   DUAL;

         CURSOR c_awd_dist_status IS
            SELECT awd.dist_status
            FROM   gms_distributions awd
            WHERE  awd.document_distribution_id  = l_distribution_id
            AND    awd.document_header_id        = l_doc_header_id
            AND    awd.document_type             = l_document_source
            AND    awd.dist_status               <>'FABA';
         BEGIN
          -- Initilaize the Object
         l_award_qty_obj :=GMS_OBJ_AWARD(GMS_TYPE_VARCHAR20(),GMS_TYPE_NUMBER(),GMS_TYPE_NUMBER());

         l_doc_header_id	:=p_doc_header_id ;
	 l_distribution_id	:=p_distribution_id ;
         l_document_source	:=p_document_source ;
         l_status		:='S';
         p_status		:=l_status ;
         l_source_type_code     := p_source_type_code;


         IF not gms_install.enabled then
		return ;
	 END IF ;

         IF NVL(p_dummy_award_id,0) >= 0 THEN
		p_status	:='S';
		Return ;
   	 END IF ;

         --==============================================================
         -- Do not proceed if grants is  enabled and Requisition type is
         -- Internal
         --==============================================================
         IF is_sponsored_project (p_project_id) THEN
            IF  nvl(l_source_type_code,'INVENTORY') = 'INVENTORY' THEN
               p_error_msg_label := 'GMS_IP_INVALID_REQ_TYPE';
               p_status :=  'E';
               return;
            END IF;
         ELSE
	  -- 2. Nonsponsored project having award should fail.
               p_error_msg_label := 'GMS_AWARD_NOT_ALLOWED';
               p_status :=  'E';
               return;
         END IF;


        GMS_POR_API.validate_dist_award(P_project_id,
         			P_task_id,
	          		P_dummy_award_id,
			        P_expenditure_type,
			        l_status,
		                l_msg_label ) ;

        IF l_status <> 'S' THEN
          p_error_msg_label:= l_msg_label ;
          p_status	  := l_status ;
          return ;
        END IF ;

	IF l_doc_header_id is NULL THEN
              OPEN  c_next_header_id;
              FETCH c_next_header_id
              INTO  l_doc_header_id;
              CLOSE c_next_header_id;
	END IF ;

	IF l_distribution_id is NULL THEN
              OPEN  c_next_dist_id;
              FETCH c_next_dist_id
              INTO  l_distribution_id;
              CLOSE c_next_dist_id;
	END IF ;

	IF l_Document_source = 'IREQ' THEN
		l_document_source:= 'REQ' ;
	END IF ;

         --===========================================
         -- Insert Records into gms_distribution table
         --===========================================
         INSERT INTO gms_distributions
                       ( document_header_id ,
                         document_distribution_id,
                         document_type,
                         gl_date,
                         project_id,
                         task_id,
                         expenditure_type,
                         expenditure_organization_id,
                         expenditure_item_date,
                         quantity,
                         unit_price,
                         amount,
                         dist_status,
                         creation_date)
            VALUES     ( l_doc_header_id,
                         l_distribution_id,
                         l_document_source,
                         p_gl_encumbered_date,
                         p_project_id,
                         p_task_id,
                         p_expenditure_type,
                         p_expenditure_organization_id,
                         p_expenditure_item_date,
                         p_quantity,
                         p_unit_price,
                         p_func_amount,
                         NULL,
                         SYSDATE );

       GMS_AWARD_DIST_ENG.PROC_DISTRIBUTE_RECORDS(l_doc_header_id, 'REQ',l_recs_processed,l_recs_rejected);
        --process the results of PROC_DISTRIBUTE_RECORDS

        IF NVL(l_recs_processed,0) > 0 THEN
            --populate the return variables.
           SELECT            a.award_number ,
                             awdd.award_id ,
                             awdd.quantity_distributed
           BULK COLLECT INTO l_award_qty_obj.award_num,
                             l_award_qty_obj.award_id,
                             l_award_qty_obj.quantity
           FROM              gms_distribution_details awdd,
                             gms_distributions        awd,
                             gms_awards_all           a
           WHERE             awd.document_distribution_id  = awdd.document_distribution_id
           AND               awd.document_header_id        = awdd.document_header_id
           AND               awd.document_distribution_id  = l_distribution_id
           AND               awd.document_header_id        = l_doc_header_id
           AND               awd.document_type             = l_document_source
           AND               awd. dist_status              = 'FABA'
           AND               awdd.award_id                 = a.Award_id;
        END IF;

         IF NVL(l_recs_rejected,0) > 0 THEN

            l_status :='E';--failed status
            OPEN   c_awd_dist_status;
            FETCH  c_awd_dist_status INTO l_dist_status;
            CLOSE  c_awd_dist_status;

           IF l_dist_status ='ERR01' THEN
              l_msg_label := 'GMS_FP_VALIDATION_FAILED';
              --Unable to distribute because funding pattern didn't pass validations
           ELSIF  l_dist_status ='ERR02' THEN
              l_msg_label := 'GMS_FP_NOT_FOUND';
              --Unable to distribute because funding pattern not found
           ELSIF  l_dist_status ='ERR03' THEN
              l_msg_label := 'GMS_FP_CHECK_FUNDS_FAILED';
              -- Unable to distribute because funding pattern doesn't have enough funds

           END IF;

         END IF;

         p_status        := l_status;
         p_award_qty_obj := l_award_qty_obj;

         IF l_msg_label IS NOT  NULL THEN
            P_error_msg_label :=l_msg_label;
         END IF;


         EXCEPTION
           WHEN OTHERS THEN
              p_status :='U';
              p_error_msg_label :='GMS_UNDEFINED_EXCEPTION';
         END distribute_award;


	FUNCTION enabled return varchar2 is
	begin
		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================
		IF gms_install.enabled then
			return 'Y' ;
		END IF ;

		return 'N' ;
	END ;

END GMS_POR_API;

/
