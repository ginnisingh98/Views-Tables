--------------------------------------------------------
--  DDL for Package Body INV_RESERVATIONS_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RESERVATIONS_INTERFACE" as
/* $Header: INVRSV5B.pls 120.2.12010000.3 2009/05/20 05:59:34 juherber ship $ */

-- Global constant holding the package name
g_pkg_name constant varchar2(50) := 'INV_RESERVATIONS_INTERFACE';

PROCEDURE debug (p_message IN VARCHAR2,p_module_name IN VARCHAR2,p_level IN NUMBER) IS
BEGIN
      inv_log_util.TRACE (p_message,g_pkg_name||'.'||p_module_name, p_level);
END debug;

/*
** ===========================================================================
** Procedure:
**	rsv_interface_manager
**
** Description:
** 	rsv interface manager processes reservations requests in
** background.
** 	Applications in need of reservations processing such as
** Create Reservations, Update Reservations, Delete Reservations and
** Transfer Reservations can write their specific requests with details such
** as item, organization, demand, supply, inventory controls and quantity
** information into MTL_RESERVATIONS_INTERFACE table.
**	rsv interface manager thru another program, rsv
** batch processor, processes records from MTL_RESERVATIONS_INTERFACE table
** into MTL_RESERVATIONS table, one or more reservation batch id(s) at a time.
** A reservation batch id consists of one or more reservations processing
** requests in MTL_RESERVATIONS_INTERFACE table. Processing includes data
** validation, executions of appropriate reservation APIs, thereby writing
** into MTL_RESERVATIONS table and finally deleting successfuly processed
** records from MTL_RESERVATIONS_INTERFACE table.
**
** Input Parameters:
**  	p_api_version_number
**		parameter to compare API version
** 	p_init_msg_lst
**		flag indicating if message list should be initialized
** 	p_form_mode
**		'Y','y' - called from form
**		'N','n' - not called from form
**
** Output Parameters:
** 	x_errbuf
**		mandatory concurrent program parameter
** 	x_retcode
**		mandatory concurrent program parameter
**
** Tables Used:
** 	MTL_RESERVATIONS_INTERFACE for Read and Update.
**
** Current Version 1.0
** Initial Version 1.0
** ===========================================================================
*/

PROCEDURE rsv_interface_manager(
  x_errbuf	       OUT NOCOPY VARCHAR2
, x_retcode            OUT NOCOPY NUMBER
, p_api_version_number IN  NUMBER   DEFAULT 1.0
, p_init_msg_lst       IN  VARCHAR2 DEFAULT fnd_api.g_false
, p_form_mode          IN  VARCHAR2 DEFAULT 'N') as

-- Constants
   c_max_numof_lines    constant number      := 3;
   c_max_string_size    constant number      := 32000;
   c_delimiter          constant varchar2(1) := ':';
   c_api_name           constant varchar2(30):= 'rsv_interface_manager';
   c_api_version_number constant number      := 1.0;

-- Variables
   l_curr_batch_id	number;
   l_curr_numof_lines	number          := 0;
   l_numof_lines        number          := 0;
   l_batch_array_arg	varchar2(32000) := NULL;
   l_batch_arg          varchar2(10)    := NULL;
   l_conc_status        boolean;

   l_return_status      varchar2(1);
   l_msg_count          number;
   l_msg_data           varchar2(1000);

-- Cursor
   cursor mric is
     select
       reservation_batch_id
     , count(*) total_num
     from mtl_reservations_interface mri1
     where mri1.transaction_mode         = 3 /* Background */
     and   mri1.row_status_code          = 1 /* Active     */
     and   mri1.error_code is null           /* No errors  */
     and   mri1.error_explanation is null    /* No errors  */
     and   mri1.lock_flag                = 2 /* No         */
     and   not exists(
            select 1 from mtl_reservations_interface mri2
            where mri1.reservation_batch_id     = mri2.reservation_batch_id
            and   mri2.transaction_mode         = 3
            and  (mri2.row_status_code         <> 1  or
                  mri2.error_code is not null        or
                  mri2.error_explanation is not null or
                  mri2.lock_flag                = 1)
                     )
     group by reservation_batch_id;

-- Cursor Rowtype
   mric_row mric%rowtype;
begin

  /*
  ** Standard call to check for call compatibility
  */
  if not fnd_api.compatible_api_call(
           c_api_version_number
         , p_api_version_number
         , c_api_name
         , g_pkg_name) then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  /*
  ** Initialize message list
  */
  if fnd_api.to_boolean(p_init_msg_lst) then
    fnd_msg_pub.initialize;
  end if;

  /*
  ** Initialize return status to success
  */
  l_return_status := fnd_api.g_ret_sts_success;

  if (p_form_mode in ('N','n')) then
        fnd_message.set_name('INV', 'INV_RSV_MANAGER');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.put_line(fnd_file.log,' ');
  end if;

  /*
  ** ========================================================================
  ** To achieve efficiency, the batch processor is designed to process 1 or
  ** more batches at a time.
  ** Remember, a batch is composed of 1 or more lines. The maximum number
  ** of lines a batch processor can process is pre-set in this program.
  **
  ** Loop thru cursor, fetching a batch id and its number of lines, each time.
  ** Group batches together until the maximum number of lines limit is reached
  ** or there are no more batches. Call the batch processor, passing the
  ** grouped batches. Repeat this process while you are still in the loop.
  ** ========================================================================
  */

  for mric_row in mric
  loop
     l_curr_batch_id    := mric_row.reservation_batch_id;
     l_curr_numof_lines := mric_row.total_num;

     if (l_curr_numof_lines > c_max_numof_lines) then
	l_batch_arg := to_char(l_curr_batch_id) || c_delimiter;

        -- dbms_output.put_line(l_batch_arg);

        if (p_form_mode in ('N','n')) then
        	-- kgm_msg
        	fnd_message.set_name('INV', 'INV_RSV_BATCHES');
        	fnd_message.set_token('BATCHES',l_batch_arg);
        	fnd_message.set_token('LINES',to_char(l_curr_numof_lines));
        	fnd_file.put_line(fnd_file.log,fnd_message.get);
        	fnd_file.put_line(fnd_file.log,' ');

                /*
           	fnd_file.put(fnd_file.log,'Reservation Batches submitted - ');
        	fnd_file.put_line(fnd_file.log,l_batch_arg);

        	fnd_file.put(fnd_file.log,'Total number of request lines - ');
        	fnd_file.put_line(fnd_file.log,to_char(l_curr_numof_lines));
        	fnd_file.put_line(fnd_file.log,' ');
		*/
        end if;

	-- Submit request
	-- rsv_interface_batch_processor
	-- (
	--   l_batch_arg
	-- , 3   /* Background */
        -- , 2   /* No Partial processing */
        -- , 'Y' /* Commit */
	-- )
	rsv_interface_batch_processor(
          p_api_version_number         => 1.0
        , p_init_msg_lst               => fnd_api.g_false
        , p_reservation_batches        => l_batch_arg
        , p_process_mode	       => 3  /* Background */
        , p_partial_batch_process_flag => 2  /* No Partial Processing */
        , p_commit_flag		       => 'Y'/* Commit */
        , p_form_mode		       => 'N'/* Not from form */
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data);

     elsif (((l_curr_numof_lines + l_numof_lines) > c_max_numof_lines) or
            (length(l_batch_array_arg        ||
                    to_char(l_curr_batch_id) ||
		    c_delimiter) > c_max_string_size)) then

           -- dbms_output.put_line(l_batch_array_arg);

           if (p_form_mode in ('N','n')) then
           	-- kgm_msg
           	fnd_message.set_name('INV', 'INV_RSV_BATCHES');
           	fnd_message.set_token('BATCHES',l_batch_array_arg);
           	fnd_message.set_token('LINES',to_char(l_numof_lines));
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
           	fnd_file.put_line(fnd_file.log,' ');

		/*
           	fnd_file.put(fnd_file.log,'Reservation Batches submitted - ');
           	fnd_file.put_line(fnd_file.log,l_batch_array_arg);

           	fnd_file.put(fnd_file.log,'Total number of request lines - ');
           	fnd_file.put_line(fnd_file.log,to_char(l_numof_lines));
           	fnd_file.put_line(fnd_file.log,' ');
		*/
           end if;

	   -- Submit request
	   -- rsv_interface_batch_processor
	   -- (
	   --   l_batch_array_arg
	   -- , 3   /* Background */
           -- , 2   /* No Partial processing */
           -- , 'Y' /* Commit */
	   -- )

	   rsv_interface_batch_processor(
             p_api_version_number         => 1.0
           , p_init_msg_lst               => fnd_api.g_false
           , p_reservation_batches        => l_batch_array_arg
           , p_process_mode	          => 3  /* Background */
           , p_partial_batch_process_flag => 2  /* No Partial Processing */
           , p_commit_flag		  => 'Y'/* Commit */
           , p_form_mode	          => 'N'/* Not from form */
           , x_return_status              => l_return_status
           , x_msg_count                  => l_msg_count
           , x_msg_data                   => l_msg_data);

           -- Reset
	   l_batch_array_arg := NULL;
           l_numof_lines     := 0;

           l_batch_array_arg := to_char(l_curr_batch_id)	||
				c_delimiter;

           l_numof_lines := l_curr_numof_lines;

     else
           l_batch_array_arg := l_batch_array_arg  	        ||
                                to_char(l_curr_batch_id)	||
				c_delimiter;

           l_numof_lines := l_numof_lines + l_curr_numof_lines;

     end if;
  end loop;

  /*
  ** If needed, call for the last time.
  */
  if (l_batch_array_arg is not null) then

           -- dbms_output.put_line(l_batch_array_arg);

           if (p_form_mode in ('N', 'n')) then
           	-- kgm_msg
           	fnd_message.set_name('INV', 'INV_RSV_BATCHES');
           	fnd_message.set_token('BATCHES',l_batch_array_arg);
           	fnd_message.set_token('LINES',to_char(l_numof_lines));
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
           	fnd_file.put_line(fnd_file.log, ' ');

		/*
           	fnd_file.put(fnd_file.log,'Reservation Batches submitted - ');
           	fnd_file.put_line(fnd_file.log,l_batch_array_arg);

           	fnd_file.put(fnd_file.log,'Total number of request lines - ');
           	fnd_file.put_line(fnd_file.log,to_char(l_numof_lines));
           	fnd_file.put_line(fnd_file.log, ' ');
		*/
	   end if;

	   -- Submit request
	   -- rsv_interface_batch_processor
	   -- (
	   --   l_batch_array_arg
	   -- , 3   /* Background */
           -- , 2   /* No Partial processing */
           -- , 'Y' /* Commit */
	   -- )

	   rsv_interface_batch_processor(
             p_api_version_number         => 1.0
           , p_init_msg_lst               => fnd_api.g_false
           , p_reservation_batches        => l_batch_array_arg
           , p_process_mode	          => 3  /* Background */
           , p_partial_batch_process_flag => 2  /* No Partial Processing */
           , p_commit_flag		  => 'Y'/* Commit */
           , p_form_mode	          => 'N'/* Not from form */
           , x_return_status              => l_return_status
           , x_msg_count                  => l_msg_count
           , x_msg_data                   => l_msg_data);
  end if;

  l_conc_status := fnd_concurrent.set_completion_status('NORMAL','NORMAL');

  exception
    when fnd_api.g_exc_error then
      l_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(
        p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(l_msg_count);
      end if;

      l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');

    when fnd_api.g_exc_unexpected_error then
      l_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(
        p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(l_msg_count);
      end if;

      l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');

    when others then
      l_return_status := fnd_api.g_ret_sts_unexp_error;

      if (fnd_msg_pub.check_msg_level
         (fnd_msg_pub.g_msg_lvl_unexp_error))then
         fnd_msg_pub.add_exc_msg(g_pkg_name,c_api_name);
      end if;

      fnd_msg_pub.count_and_get(
        p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(l_msg_count);
      end if;

      l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');

end rsv_interface_manager;

/*
** ===========================================================================
** Procedure:
**	rsv_interface_batch_processor
**
** Description:
** 	Applications in need of reservations processing such as
** Create Reservations, Update Reservations, Delete Reservations and
** Transfer Reservations can write their specific requests with details such
** as item, organization, demand, supply, inventory controls and quantity
** information into MTL_RESERVATIONS_INTERFACE table.
**	rsv interface batch processor, processes records from
** MTL_RESERVATIONS_INTERFACE table into MTL_RESERVATIONS table, one or more
** reservation batch id(s) at a time. A reservation batch id consists of one
** or more reservations processing requests in MTL_RESERVATIONS_INTERFACE table.
** A reservations request in MTL_RESERVATIONS_INTERFACE table is uniquely
** determined by a reservations interface id.
**	rsv interface batch processor in turn calls another program,
** rsv interface line processor repetitively, passing each time a
** reservations interafce id under the current reservations batch id.
** reservations interface line processor performs the actual reservations
** processing.
** 	rsv interface batch processor deletes successfully processed
** rows from MTL_RESERVATIONS_INTERFACE table.
**
** Input Parameters:
**  	p_api_version_number
**		parameter to compare API version
** 	p_init_msg_lst
**		flag indicating if message list should be initialized
**	p_reservation_batches
**        	reservation batch ids stringed together and separated by
**              delimiter.Eg: 163:716:987:
**      p_process_mode
**		1 = Online 2 = Concurrent 3 = Background
**      p_partial_batch_processing_flag
**		1 - If a line in reservation batch fails, continue
**		2 - If a line in reservation batch fails, exit
**      p_commit_flag
** 		'Y','y'      - Commit
**              not('Y','y') - Do not commit
** 	p_form_mode
**		'Y','y' - called from form
**		'N','n' - not called from form
**
** Output Parameters:
** 	x_return_status
**		return status indicating success, error, unexpected error
** 	x_msg_count
**		number of messages in message list
** 	x_msg_data
**		if the number of messages in message list is 1, contains
**		message text
**
** Tables Used:
** 	MTL_RESERVATIONS_INTERFACE for Read, Update and Delete.
**
** Current Version 1.0
** Initial Version 1.0
** ===========================================================================
*/

PROCEDURE rsv_interface_batch_processor (
  p_api_version_number         IN  NUMBER
, p_init_msg_lst               IN  VARCHAR2 DEFAULT fnd_api.g_false
, p_reservation_batches        IN  VARCHAR2
, p_process_mode	       IN  NUMBER   DEFAULT 1
, p_partial_batch_process_flag IN  NUMBER   DEFAULT 1
, p_commit_flag		       IN  VARCHAR2 DEFAULT 'Y'
, p_form_mode                  IN  VARCHAR2 DEFAULT 'N'
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2) as

-- Constants
   c_delimiter          constant varchar2(1) := ':';
   c_api_name           constant varchar2(30):= 'rsv_interface_batch_processor';
   c_api_version_number constant number      := 1.0;

-- Variables
   l_position            number;
   l_batch_id            number;
   l_interface_id        number;
   l_return_status       varchar2(1);
   l_error_code          number;
   l_error_text          varchar2(3000); -- Bug 5529609
   l_delete_rows         boolean;
   l_reservation_batches varchar2(32000);
   l_conc_status         boolean;

-- Cursor
   cursor mric(batch_id     number,
               process_mode number) is
     select reservation_interface_id
     from mtl_reservations_interface mri
     where mri.reservation_batch_id = batch_id
     and   mri.row_status_code      = 1 /* Active */
     and   mri.transaction_mode     = process_mode
     and   mri.error_code is null
     and   mri.error_explanation is null
     and   mri.lock_flag            = 1 /* Yes */;

-- Cursor Rowtype
   mric_row mric%rowtype;
begin
  /*
  ** Standard call to check for call compatibility
  */
  if not fnd_api.compatible_api_call(
           c_api_version_number
         , p_api_version_number
         , c_api_name
         , g_pkg_name) then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  /*
  ** Initialize message list
  */
  if fnd_api.to_boolean(p_init_msg_lst) then
    fnd_msg_pub.initialize;
  end if;

  /*
  ** Initialize return status to success
  */
  x_return_status := fnd_api.g_ret_sts_success;

  l_reservation_batches := rtrim(ltrim(p_reservation_batches));

  while (0=0) loop
    /*
    ** Following lines of logic unstrings batch ids from stringed batch ids
    */
    l_position := instr(nvl(l_reservation_batches,'A'),c_delimiter);

    if (l_position = 0)then
	-- Out of loop; No more batches to process;
	exit;
    end if;

    l_batch_id := to_number(substr(l_reservation_batches, 1, l_position - 1));

    if (l_position = length(l_reservation_batches)) then
        -- for last batch
      	l_reservation_batches := NULL;
    else
        l_reservation_batches := substr(l_reservation_batches,l_position + 1);
    end if;

    -- Record this point
    savepoint alpha;

    -- Lock requests for reservation batch id
    update mtl_reservations_interface
    set lock_flag = 1 /* Yes */
    where reservation_batch_id = l_batch_id
    and   row_status_code      = 1	/* Active */
    and   lock_flag            = 2 	/* No     */
    and   transaction_mode     = p_process_mode
    and   error_code is null
    and   error_explanation is null;

    if (SQL%ROWCOUNT <> 0) then
      l_delete_rows := true;

      for mric_row in mric(l_batch_id, p_process_mode) loop

    	-- Initialize
        l_interface_id  := mric_row.reservation_interface_id;
        l_return_status := fnd_api.g_ret_sts_success;
        l_error_code    := null;
        l_error_text    := null;

        if (p_form_mode in ('N','n')) then
        	-- kgm_msg
        	fnd_message.set_name('INV', 'INV_RSV_BATCH_INTERFACE');
        	fnd_message.set_token('BATCH_ID',to_char(l_batch_id));
        	fnd_message.set_token('INTERFACE_ID',to_char(l_interface_id));
        	fnd_file.put_line(fnd_file.log,fnd_message.get);
        	fnd_file.put_line(fnd_file.log,' ');

		/*
        	fnd_file.put(fnd_file.log,'Reservation Batch - ');
		fnd_file.put(fnd_file.log, to_char(l_batch_id));
        	fnd_file.put(fnd_file.log,', Reservation Interface - ');
		fnd_file.put(fnd_file.log, to_char(l_interface_id));
		fnd_file.put_line(fnd_file.log, ' submitted ');
        	fnd_file.put_line(fnd_file.log,' ');
		*/
	end if;

	-- Call rsv_interface_line_processor
	rsv_interface_line_processor (
          p_api_version_number	      => 1.0
	, p_init_msg_lst              => fnd_api.g_false
        , p_reservation_interface_id  => l_interface_id
        , p_form_mode	              => p_form_mode
        , x_error_code		      => l_error_code
        , x_error_text                => l_error_text
        , x_return_status             => l_return_status
        , x_msg_count                 => x_msg_count
        , x_msg_data                  => x_msg_data);

	/*
	** If partial batch processing flag has a value of 2, then all
        ** requests of a batch have to be successfully processed. Even if
	** one fails, processing shouldn't continue for the others. However,
        ** for a value of 1, processing should continue for others when one
	** fails.
        */

        if ((l_return_status <> fnd_api.g_ret_sts_success or
             l_error_text is not null                     or
             l_error_code is not null)                    and
            (p_partial_batch_process_flag = 2))then

		-- Rollback
		rollback to savepoint alpha;

		-- Stamp error. rollback should have unlocked rows.
                update mtl_reservations_interface
                set
                  row_status_code = 3  /* Error */
		, error_code        = l_error_code
		, error_explanation = substrb(l_error_text,1,240) -- Bug 5529609
		where reservation_interface_id = l_interface_id;

		l_delete_rows := false;

		exit;
        end if;

        if ((l_return_status <> fnd_api.g_ret_sts_success or
             l_error_text is not null                     or
             l_error_code is not null)                    and
            (p_partial_batch_process_flag = 1))then

		-- Stamp error. Unlock rows.
                update mtl_reservations_interface
                set
                  row_status_code   = 3  /* Error */
                , lock_flag         = 2  /* No    */
		, error_code        = l_error_code
		, error_explanation = substrb(l_error_text,1,240) -- Bug 5529609
		where reservation_interface_id = l_interface_id;
	end if;

      end loop;

      -- Delete processed rows
      if (l_delete_rows = true) then
	delete mtl_reservations_interface
	where reservation_batch_id = l_batch_id
	and   transaction_mode     = p_process_mode
	and   row_status_code      = 2 /* Completed */
	and   error_code is null
	and   error_explanation is null;
      end if;

      -- Commit only if explicitly told to do so
      if (p_commit_flag in ('Y', 'y')) then
	commit;
      end if;

    end if; /* (SQL%ROWCOUNT <> 0) */
  end loop;

  -- l_conc_status := fnd_concurrent.set_completion_status('NORMAL','NORMAL');

  exception
    when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(
        p_count   => x_msg_count
      , p_data    => x_msg_data
      , p_encoded => 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(x_msg_count);
      end if;

      --l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');

    when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(
        p_count   => x_msg_count
      , p_data    => x_msg_data
      , p_encoded => 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(x_msg_count);
      end if;

      --l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');

    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      if (fnd_msg_pub.check_msg_level
         (fnd_msg_pub.g_msg_lvl_unexp_error))then
         fnd_msg_pub.add_exc_msg(g_pkg_name,c_api_name);
      end if;

      fnd_msg_pub.count_and_get(
        p_count   => x_msg_count
      , p_data    => x_msg_data
      , p_encoded => 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(x_msg_count);
      end if;

      --l_conc_status := fnd_concurrent.set_completion_status('ERROR','ERROR');
end rsv_interface_batch_processor;

/*
** ===========================================================================
** Procedure:
**	rsv_interface_line_processor
**
** Description:
** 	Applications in need of reservations processing such as
** Create Reservations, Update Reservations, Delete Reservations and
** Transfer Reservations can write their specific requests with details such
** as item, organization, demand, supply, inventory controls and quantity
** information into MTL_RESERVATIONS_INTERFACE table.
** 	rsv interface line processor processes the reservations
** request line in MTL_RESERVATIONS_INTERFACE, pointed by a given
** reservations interface id. Processing includes data validation and
** performing the requested reservation function by executing the appropriate
** reservations API.
**
** Input Parameters:
**  	p_api_version_number
**		parameter to compare API version
** 	p_init_msg_lst
**		flag indicating if message list should be initialized
**	p_reservation interface id
**		identifies reservations request line in
**		MTL_RESERVATIONS_INTERFACE table.
** 	p_form_mode
**		'Y','y' - called from form
**		'N','n' - not called from form
**
** Output Parameters:
**	x_error_code
**		error code
** 	x_error_text
**		error explanation text
** 	x_return_status
**		return status indicating success, error, unexpected error
** 	x_msg_count
**		number of messages in message list
** 	x_msg_data
**		if the number of messages in message list is 1, contains
**		message text
**
** Tables Used:
** 	MTL_RESERVATIONS_INTERFACE for Read and Update.
**
** Current Version 1.0
** Initial Version 1.0
** ===========================================================================
*/

PROCEDURE rsv_interface_line_processor (
  p_api_version_number        IN  NUMBER
, p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
, p_reservation_interface_id  IN  NUMBER
, p_form_mode                 IN  VARCHAR2 DEFAULT 'N'
, x_error_code		      OUT NOCOPY NUMBER
, x_error_text                OUT NOCOPY VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2) as

-- Constants
   c_api_name           constant varchar2(30):= 'rsv_interface_line_processor';
   c_api_version_number constant number      := 1.0;

-- Variables

   /*
   ** Structures that will be loaded and passed to reservation APIs
   */
   l_rsv_rec    	inv_reservation_global.mtl_reservation_rec_type;
   l_to_rsv_rec 	inv_reservation_global.mtl_reservation_rec_type;

   /*
   ** Variables to hold fetched data from mtl_reservations_interface
   */
   l_requirement_date     		date;
   l_organization_id    		number;
   l_inventory_item_id  		number;
   l_demand_source_type_id 		number;
   l_demand_source_name         	varchar2(30);
   l_demand_source_header_id    	number;
   l_demand_source_line_id      	number;
   l_primary_uom_code           	varchar2(3);
   l_primary_uom_id             	number;
   l_secondary_uom_code                 varchar2(3);    -- INVCONV
   l_secondary_uom_id                   number;         -- INVCONV
   l_reservation_uom_code       	varchar2(3);
   l_reservation_uom_id         	number;
   l_reservation_quantity       	number;
   l_primary_rsv_quantity		number;
   l_secondary_rsv_quantity             number;         -- INVCONV
   l_supply_source_type_id 		number;
   l_supply_source_name         	varchar2(30);
   l_supply_source_header_id    	number;
   l_supply_source_line_id      	number;
   l_supply_source_line_detail  	number;
   l_revision				varchar2(3);
   l_subinventory_code			varchar2(10);
   l_subinventory_id                    number;
   l_locator_id				number;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_lot_number				varchar2(80);
   l_lot_number_id                      number;
   l_lpn_id				number;

   l_to_organization_id    		number;
   l_to_demand_source_type_id 		number;
   l_to_demand_source_name         	varchar2(30);
   l_to_demand_source_header_id    	number;
   l_to_demand_source_line_id      	number;
   l_to_supply_source_type_id 		number;
   l_to_supply_source_name         	varchar2(30);
   l_to_supply_source_header_id    	number;
   l_to_supply_source_line_id      	number;
   l_to_supply_source_line_detail  	number;
   l_to_revision			varchar2(3);
   l_to_subinventory_code		varchar2(10);
   l_to_subinventory_id                 number;
   l_to_locator_id			number;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_to_lot_number			varchar2(80);
   l_to_lot_number_id                   number;
   l_to_lpn_id				number;

   l_reservation_action_code		number;
   l_validation_flag			number;
   l_partial_quantities_allowed		number;
   l_ship_ready_flag		        number;

   /*
   ** Return status of reservation APIs
   */
   l_return_status      varchar2(1);

   /*
   ** Other output parameters of reservation APIs
   */
   l_serial_number              inv_reservation_global.serial_number_tbl_type;
   l_partial_reservation_flag	varchar2(1);
   l_quantity_reserved		number;
   l_secondary_quantity_reserved number;
   l_quantity_transferred	number;
   l_reservation_id		number;
   l_attribute_category		varchar2(30);
   l_attribute1			varchar2(150);
   l_attribute2			varchar2(150);
   l_attribute3			varchar2(150);
   l_attribute4			varchar2(150);
   l_attribute5			varchar2(150);
   l_attribute6			varchar2(150);
   l_attribute7 		varchar2(150);
   l_attribute8			varchar2(150);
   l_attribute9			varchar2(150);
   l_attribute10		varchar2(150);
   l_attribute11		varchar2(150);
   l_attribute12		varchar2(150);
   l_attribute13		varchar2(150);
   l_attribute14		varchar2(150);
   l_attribute15		varchar2(150);
   l_oe_line_subinventory       varchar2(10);  --Bug 3357096
   l_tmp_quantity               number := NULL; --Bug 3384601
   l_mso_sales_order_id         number := NULL; --Bug 8237995
   l_oe_order_header_id         number := NULL; --Bug 8237995

-- Exception
   INVALID_ACTION_CODE 		exception;

begin
  /*
  ** Standard call to check for call compatibility
  */
  if not fnd_api.compatible_api_call(
           c_api_version_number
         , p_api_version_number
         , c_api_name
         , g_pkg_name) then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  /*
  ** Initialize message list
  */
  if fnd_api.to_boolean(p_init_msg_lst) then
    fnd_msg_pub.initialize;
  end if;

  /*
  ** Initialize return status to success
  */
  x_return_status := fnd_api.g_ret_sts_success;
  x_error_code    := NULL;
  x_error_text    := NULL;

  /*
  ** Fetch record from mtl_reservations_interface for the given reservation
  ** interface id.
  */
  -- INVCONV - Incorporate secondary columns into select
  select
    requirement_date
  , organization_id
  , inventory_item_id
  , demand_source_type_id
  , demand_source_name
  , demand_source_header_id
  , demand_source_line_id
  , primary_uom_code
  , primary_uom_id
  , secondary_uom_code
  , secondary_uom_id
  , reservation_uom_code
  , reservation_uom_id
  , reservation_quantity
  , primary_reservation_quantity
  , secondary_reservation_quantity
  , supply_source_type_id
  , supply_source_name
  , supply_source_header_id
  , supply_source_line_id
  , supply_source_line_detail
  , revision
  , subinventory_code
  , subinventory_id
  , locator_id
  , lot_number
  , lot_number_id
  , to_organization_id
  , to_demand_source_type_id
  , to_demand_source_name
  , to_demand_source_header_id
  , to_demand_source_line_id
  , to_supply_source_type_id
  , to_supply_source_name
  , to_supply_source_header_id
  , to_supply_source_line_id
  , to_supply_source_line_detail
  , to_revision
  , to_subinventory_code
  , to_subinventory_id
  , to_locator_id
  , to_lot_number
  , to_lot_number_id
  , reservation_action_code
  , validation_flag
  , partial_quantities_allowed
  , ship_ready_flag
  , lpn_id
  , to_lpn_id
  , attribute_category
  , attribute1
  , attribute2
  , attribute3
  , attribute4
  , attribute5
  , attribute6
  , attribute7
  , attribute8
  , attribute9
  , attribute10
  , attribute11
  , attribute12
  , attribute13
  , attribute14
  , attribute15
  into
    l_requirement_date
  , l_organization_id
  , l_inventory_item_id
  , l_demand_source_type_id
  , l_demand_source_name
  , l_demand_source_header_id
  , l_demand_source_line_id
  , l_primary_uom_code
  , l_primary_uom_id
  , l_secondary_uom_code
  , l_secondary_uom_id
  , l_reservation_uom_code
  , l_reservation_uom_id
  , l_reservation_quantity
  , l_primary_rsv_quantity
  , l_secondary_rsv_quantity
  , l_supply_source_type_id
  , l_supply_source_name
  , l_supply_source_header_id
  , l_supply_source_line_id
  , l_supply_source_line_detail
  , l_revision
  , l_subinventory_code
  , l_subinventory_id
  , l_locator_id
  , l_lot_number
  , l_lot_number_id
  , l_to_organization_id
  , l_to_demand_source_type_id
  , l_to_demand_source_name
  , l_to_demand_source_header_id
  , l_to_demand_source_line_id
  , l_to_supply_source_type_id
  , l_to_supply_source_name
  , l_to_supply_source_header_id
  , l_to_supply_source_line_id
  , l_to_supply_source_line_detail
  , l_to_revision
  , l_to_subinventory_code
  , l_to_subinventory_id
  , l_to_locator_id
  , l_to_lot_number
  , l_to_lot_number_id
  , l_reservation_action_code
  , l_validation_flag
  , l_partial_quantities_allowed
  , l_ship_ready_flag
  , l_lpn_id
  , l_to_lpn_id
  , l_attribute_category
  , l_attribute1
  , l_attribute2
  , l_attribute3
  , l_attribute4
  , l_attribute5
  , l_attribute6
  , l_attribute7
  , l_attribute8
  , l_attribute9
  , l_attribute10
  , l_attribute11
  , l_attribute12
  , l_attribute13
  , l_attribute14
  , l_attribute15
  from mtl_reservations_interface
  where reservation_interface_id   = p_reservation_interface_id
  and   row_status_code            = 1 /* Active */
  and   error_code is null
  and   error_explanation is null;

  /*
  ** Populate local structures with fetched data.
  */
  l_rsv_rec.reservation_id		    := NULL;
  l_rsv_rec.requirement_date 		    := l_requirement_date;
  l_rsv_rec.organization_id  		    := l_organization_id;
  l_rsv_rec.inventory_item_id		    := l_inventory_item_id;
  l_rsv_rec.demand_source_type_id 	    := l_demand_source_type_id;
  l_rsv_rec.demand_source_name              := l_demand_source_name;
  l_rsv_rec.demand_source_header_id	    := l_demand_source_header_id;
  l_rsv_rec.demand_source_line_id           := l_demand_source_line_id;
  l_rsv_rec.demand_source_delivery          := NULL;
  l_rsv_rec.primary_uom_code                := l_primary_uom_code;
  l_rsv_rec.primary_uom_id		    := l_primary_uom_id;
  l_rsv_rec.secondary_uom_code              := l_secondary_uom_code;     -- INVCONV
  l_rsv_rec.secondary_uom_id                := l_secondary_uom_id;       -- INVCONV
  l_rsv_rec.reservation_uom_code	    := l_reservation_uom_code;
  l_rsv_rec.reservation_uom_id	            := l_reservation_uom_id;
  l_rsv_rec.reservation_quantity	    := l_reservation_quantity;
  l_rsv_rec.primary_reservation_quantity    := l_primary_rsv_quantity;
  l_rsv_rec.secondary_reservation_quantity  := l_secondary_rsv_quantity; -- INVCONV
  l_rsv_rec.autodetail_group_id		    := NULL;
  l_rsv_rec.external_source_code	    := NULL;
  l_rsv_rec.external_source_line_id  	    := NULL;
  l_rsv_rec.supply_source_type_id	    := l_supply_source_type_id;
  l_rsv_rec.supply_source_name	            := l_supply_source_name;
  l_rsv_rec.supply_source_header_id	    := l_supply_source_header_id;
  l_rsv_rec.supply_source_line_id	    := l_supply_source_line_id;
  l_rsv_rec.supply_source_line_detail	    := l_supply_source_line_detail;
  l_rsv_rec.revision			    := l_revision;
  l_rsv_rec.subinventory_code		    := l_subinventory_code;
  l_rsv_rec.subinventory_id		    := l_subinventory_id;
  l_rsv_rec.locator_id		            := l_locator_id;
  l_rsv_rec.lot_number                      := l_lot_number;
  l_rsv_rec.lot_number_id                   := l_lot_number_id;
  l_rsv_rec.pick_slip_number         	    := NULL;
  l_rsv_rec.lpn_id                   	    := l_lpn_id;
  l_rsv_rec.attribute_category		    := l_attribute_category;
  l_rsv_rec.attribute1			    := l_attribute1;
  l_rsv_rec.attribute2			    := l_attribute2;
  l_rsv_rec.attribute3			    := l_attribute3;
  l_rsv_rec.attribute4			    := l_attribute4;
  l_rsv_rec.attribute5			    := l_attribute5;
  l_rsv_rec.attribute6			    := l_attribute6;
  l_rsv_rec.attribute7			    := l_attribute7;
  l_rsv_rec.attribute8			    := l_attribute8;
  l_rsv_rec.attribute9			    := l_attribute9;
  l_rsv_rec.attribute10			    := l_attribute10;
  l_rsv_rec.attribute11			    := l_attribute11;
  l_rsv_rec.attribute12			    := l_attribute12;
  l_rsv_rec.attribute13			    := l_attribute13;
  l_rsv_rec.attribute14			    := l_attribute14;
  l_rsv_rec.attribute15			    := l_attribute15;
  l_rsv_rec.ship_ready_flag		    := l_ship_ready_flag;

  l_to_rsv_rec.reservation_id		    := NULL;
  l_to_rsv_rec.requirement_date 	    := l_requirement_date;
  l_to_rsv_rec.organization_id  	    := l_to_organization_id;
  l_to_rsv_rec.inventory_item_id	    := l_inventory_item_id;
  l_to_rsv_rec.demand_source_type_id 	    := l_to_demand_source_type_id;
  l_to_rsv_rec.demand_source_name           := l_to_demand_source_name;
  l_to_rsv_rec.demand_source_header_id      := l_to_demand_source_header_id;
  l_to_rsv_rec.demand_source_line_id        := l_to_demand_source_line_id;
  l_to_rsv_rec.demand_source_delivery       := NULL;
  l_to_rsv_rec.primary_uom_code             := l_primary_uom_code;
  l_to_rsv_rec.primary_uom_id		    := l_primary_uom_id;
  l_to_rsv_rec.secondary_uom_code           := l_secondary_uom_code;       -- INVCONV
  l_to_rsv_rec.secondary_uom_id             := l_secondary_uom_id;         -- INVCONV
  l_to_rsv_rec.reservation_uom_code	    := l_reservation_uom_code;
  l_to_rsv_rec.reservation_uom_id	    := l_reservation_uom_id;
  l_to_rsv_rec.reservation_quantity	    := l_reservation_quantity;
  l_to_rsv_rec.primary_reservation_quantity := l_primary_rsv_quantity;
  l_to_rsv_rec.secondary_reservation_quantity := l_secondary_rsv_quantity; -- INVCONV
  l_to_rsv_rec.autodetail_group_id	    := NULL;
  l_to_rsv_rec.external_source_code	    := NULL;
  l_to_rsv_rec.external_source_line_id      := NULL;
  l_to_rsv_rec.supply_source_type_id	    := l_to_supply_source_type_id;
  l_to_rsv_rec.supply_source_name	    := l_to_supply_source_name;
  l_to_rsv_rec.supply_source_header_id      := l_to_supply_source_header_id;
  l_to_rsv_rec.supply_source_line_id	    := l_to_supply_source_line_id;
  l_to_rsv_rec.supply_source_line_detail    := l_to_supply_source_line_detail;
  l_to_rsv_rec.revision		            := l_to_revision;
  l_to_rsv_rec.subinventory_code	    := l_to_subinventory_code;
  l_to_rsv_rec.subinventory_id	            := l_to_subinventory_id;
  l_to_rsv_rec.locator_id		    := l_to_locator_id;
  l_to_rsv_rec.lot_number                   := l_to_lot_number;
  l_to_rsv_rec.lot_number_id                := l_to_lot_number_id;
  l_to_rsv_rec.pick_slip_number       	    := NULL;
  l_to_rsv_rec.lpn_id                  	    := l_to_lpn_id;
  l_to_rsv_rec.attribute_category	    := l_attribute_category;
  l_to_rsv_rec.attribute1		    := l_attribute1;
  l_to_rsv_rec.attribute2		    := l_attribute2;
  l_to_rsv_rec.attribute3		    := l_attribute3;
  l_to_rsv_rec.attribute4		    := l_attribute4;
  l_to_rsv_rec.attribute5		    := l_attribute5;
  l_to_rsv_rec.attribute6		    := l_attribute6;
  l_to_rsv_rec.attribute7		    := l_attribute7;
  l_to_rsv_rec.attribute8		    := l_attribute8;
  l_to_rsv_rec.attribute9		    := l_attribute9;
  l_to_rsv_rec.attribute10		    := l_attribute10;
  l_to_rsv_rec.attribute11		    := l_attribute11;
  l_to_rsv_rec.attribute12		    := l_attribute12;
  l_to_rsv_rec.attribute13		    := l_attribute13;
  l_to_rsv_rec.attribute14		    := l_attribute14;
  l_to_rsv_rec.attribute15		    := l_attribute15;
  l_to_rsv_rec.ship_ready_flag		    := l_ship_ready_flag;

-- Bug 3357096. The subinventory code cannot be different if the sub is specified at the order line
-- and the user is creating a new record for the order line with a different subinventory.
   If (l_reservation_action_code = 1) then
      If (l_rsv_rec.demand_source_type_id in (2,8)) and (l_rsv_rec.supply_source_type_id = 13) and
         (l_rsv_rec.subinventory_code is not null) then
           select subinventory into l_oe_line_subinventory from oe_order_lines_all  where
     	   line_id = l_rsv_rec.demand_source_line_id;

	   If (l_oe_line_subinventory is not null)  and (l_oe_line_subinventory <> l_rsv_rec.subinventory_code) then
	   	fnd_message.set_name('INV','INV_INVALID_SUBINVENTORY');
               	fnd_msg_pub.add;
               	raise fnd_api.g_exc_error;
	   End if;
       End if;
   End if;

--  Bug:3384601 - Uom Conversions are not happening when RESERVATION_UOM_CODE is populated in MTL_RESERVATIONS_INTERFACE
--  and processed by the Reservation Interface Manager. It was creating reservations always in primary_uom of the item.

--  Bug 3475862 added below code for update reservation too, also, calling inv_cache to get the primary_uom_code for
--  better performance.
   If (l_reservation_action_code in (1,2)) then
        IF l_rsv_rec.primary_reservation_quantity <= 0 OR l_rsv_rec.reservation_quantity <= 0  THEN
            debug('Primary Reservation Quantity or Reservation Quantity should not be equal to lessa than zero',c_api_name,1);
            fnd_message.set_name('INV', 'INV_GREATER_THAN_ZERO');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
        END IF;

	IF ( inv_cache.set_item_rec(l_rsv_rec.organization_id, l_rsv_rec.inventory_item_id) ) THEN
          	l_rsv_rec.primary_uom_code := inv_cache.item_rec.primary_uom_code;
	END IF;

        IF l_rsv_rec.reservation_uom_code IS NOT NULL THEN
           IF l_rsv_rec.primary_uom_code = l_rsv_rec.reservation_uom_code THEN
              	l_tmp_quantity := l_rsv_rec.reservation_quantity;
           ELSE
                -- Convert reservation quantity in reservation uom
                -- to primary quantity in primary uom.
                l_tmp_quantity                   := inv_convert.inv_um_convert(
                                                   item_id                      => l_rsv_rec.inventory_item_id
                                                 ,lot_number                    => l_rsv_rec.lot_number /*Bug#8290483*/
                                                 ,organization_id               => l_rsv_rec.organization_id
                                                 , PRECISION                    => NULL -- use default precision
                                                 , from_quantity                => l_rsv_rec.reservation_quantity
                                                 , from_unit                    => l_rsv_rec.reservation_uom_code
                                                 , to_unit                      => l_rsv_rec.primary_uom_code
                                                 , from_name                    => NULL -- from uom name
                                                 , to_name                      => NULL -- to uom name
                                                 );
        	IF l_tmp_quantity = -99999 THEN
          		-- conversion failed
          		debug('Cannot Convert to Primary UOM',c_api_name,1);
          		fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-PRIMARY-UOM');
          		fnd_msg_pub.ADD;
          		RAISE fnd_api.g_exc_error;
        	END IF;
            END IF;
         END IF;

         debug('Primary_reservation quantity = '||l_tmp_quantity,c_api_name,1);
         l_rsv_rec.primary_reservation_quantity  := l_tmp_quantity;

         -- Bug 3475862, copying the converted quantity to l_to_rsv_rec.primary_reservation_quantity too.
         -- For update reservation this qty will be used to update the record.
         If (l_reservation_action_code = 2) then
             l_to_rsv_rec.primary_reservation_quantity  := l_tmp_quantity;
         END IF;
   END IF;
--  Bug:3384601 -- End  of code changes

--Fix for Bug: 8237995
--Validating MSO.Sales_order_id for SO,RMA and ISO
  If (l_reservation_action_code = 1) THEN
    If l_rsv_rec.demand_source_type_id in (2,8,12) THEN
      Begin
        select sales_order_id into l_mso_sales_order_id from mtl_sales_orders
        where sales_order_id = l_rsv_rec.demand_source_header_id;
      Exception
        When No_Data_Found Then
          debug('For Sales Orders, RMA and Internal Orders DEMAND_SOURCE_HEADER_id Should be mtl_sales_order sales_order_id',c_api_name,1);
          fnd_message.set_name('INV','INV_INVALID_DEMAND_SOURCE');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
      End;
      Begin
        Select Header_ID into l_oe_order_header_id from OE_Order_Lines_All
        Where line_id = l_rsv_rec.demand_source_line_id;

        If inv_salesorder.get_salesorder_for_oeheader(l_oe_order_header_id) Is NULL
        or inv_salesorder.get_salesorder_for_oeheader(l_oe_order_header_id) <> l_mso_sales_order_id Then
          debug('This sales_order_id does not belog to the given demand_source_line_id',c_api_name,1);
          fnd_message.set_name('INV','INV_INVALID_DEMAND_SOURCE');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_error;
        End If;
      EXCEPTION
        When No_Data_Found Then
          debug('Demand_Source_line_Id does not exist',c_api_name,1);
          fnd_message.set_name('INV', 'INV_INVALID_SALES_ORDER');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      End;
    End If;
  End if;
--End of Fix for Bug: 8237995

  /*
  ** Since the table column datatype doesn't match the parameter datatype,
  ** we have to do this.
  ** l_partial_quantities 1=Yes; Not(1)=No;
  */
  if (l_partial_quantities_allowed = 1) then
  	l_partial_reservation_flag := fnd_api.g_true;
  else
  	l_partial_reservation_flag := fnd_api.g_false;
  end if;

  /*
  ** Initialize parameter return status
  */
  l_return_status := fnd_api.g_ret_sts_success;

  /*
  ** For not(insert) requests quantity should be a value of don't care
  ** for a successful retrieval of source record.
  */
  if (l_reservation_action_code in (2,3,4)) then
  	l_rsv_rec.reservation_quantity	        := fnd_api.g_miss_num;
  	l_rsv_rec.primary_reservation_quantity  := fnd_api.g_miss_num;
        l_rsv_rec.secondary_reservation_quantity:= fnd_api.g_miss_num; -- INVCONV
  end if;

  /*
  ** Call appropriate API based on action code
  ** 1. Create   reservation
  ** 2. Update   reservation
  ** 3. Delete   reservation
  ** 4. Transfer reservation
  */

  if (l_reservation_action_code = 1) then
	-- Create reservation

	inv_reservation_pub.create_reservation(
          p_api_version_number	        => 1.0
	, p_init_msg_lst		=> fnd_api.g_false
	, x_return_status		=> l_return_status
	, x_msg_count			=> x_msg_count
	, x_msg_data			=> x_msg_data
	, p_rsv_rec			=> l_rsv_rec
	, p_serial_number		=> l_serial_number
	, x_serial_number		=> l_serial_number
	, p_partial_reservation_flag	=> l_partial_reservation_flag
 	, p_force_reservation_flag	=> fnd_api.g_false
	, p_validation_flag		=> fnd_api.g_true
	, x_quantity_reserved		=> l_quantity_reserved
        , x_secondary_quantity_reserved => l_secondary_quantity_reserved    --INVCONV
	, x_reservation_id		=> l_reservation_id);

        if (l_return_status = fnd_api.g_ret_sts_success) then
           x_return_status := l_return_status;

           if (p_form_mode in ('N','n')) then
           	-- kgm_msg
           	fnd_message.set_name('INV', 'INV_RSV_INTERFACE_SUCCESS');
           	fnd_message.set_token('INTERFACE_ID',
           		to_char(p_reservation_interface_id));
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
           	fnd_file.put_line(fnd_file.log,' ');

		/*
           	fnd_message.set_name('INV', 'RSV_INTERFACE_SUCCESS');
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
	   	fnd_file.put(fnd_file.log, 'Reservation Interface Id: ');
	   	fnd_file.put_line(fnd_file.log,
                             to_char(p_reservation_interface_id));

	   	fnd_file.put(fnd_file.log, 'Quantity Reserved: ');
	   	fnd_file.put_line(fnd_file.log,
                             to_char(l_quantity_reserved));

	   	fnd_file.put(fnd_file.log, 'Secondary Quantity Reserved: ');   --INVCONV
	   	fnd_file.put_line(fnd_file.log,
                             to_char(l_secondary_quantity_reserved));  -- INVCONV

	   	fnd_file.put(fnd_file.log, 'Reservation Id: ');
	   	fnd_file.put_line(fnd_file.log,
                             to_char(l_reservation_id));
           	fnd_file.put_line(fnd_file.log,' ');
		*/
	   end if;

        elsif (l_return_status = fnd_api.g_ret_sts_error) then
	   raise fnd_api.g_exc_error;
        elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
	   raise fnd_api.g_exc_unexpected_error;
        end if;

  elsif (l_reservation_action_code = 2) then
	-- Update reservation
-- Adeed the extra parameter for call to update_reservations
-- Bug Number 3392957
	inv_reservation_pub.update_reservation(
                                     p_api_version_number        => 1.0
                                   , p_init_msg_lst	           => fnd_api.g_false
                                   , x_return_status	           => l_return_status
                                   , x_msg_count		           => x_msg_count
                                   , x_msg_data		              => x_msg_data
	                                , p_original_rsv_rec	        => l_rsv_rec
	                                , p_to_rsv_rec	              => l_to_rsv_rec
	                                , p_original_serial_number	  => l_serial_number
	                                , p_to_serial_number	        => l_serial_number
	                                , p_validation_flag	        => fnd_api.g_true
                                   , p_check_availability        => fnd_api.g_true
                                         );

        if (l_return_status = fnd_api.g_ret_sts_success) then
           x_return_status := l_return_status;

           if (p_form_mode in ('N','n')) then
           	-- kgm_msg
           	fnd_message.set_name('INV', 'INV_RSV_INTERFACE_SUCCESS');
           	fnd_message.set_token('INTERFACE_ID',
           		to_char(p_reservation_interface_id));
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
           	fnd_file.put_line(fnd_file.log,' ');

		/*
           	fnd_message.set_name('INV', 'RSV_INTERFACE_SUCCESS');
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
	   	fnd_file.put(fnd_file.log, 'Reservation Interface Id: ');
	   	fnd_file.put_line(fnd_file.log,
                             to_char(p_reservation_interface_id));
           	fnd_file.put_line(fnd_file.log,' ');
		*/
	   end if;

        elsif (l_return_status = fnd_api.g_ret_sts_error) then
	   raise fnd_api.g_exc_error;
        elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
	   raise fnd_api.g_exc_unexpected_error;
        end if;

  elsif (l_reservation_action_code = 3) then
	-- Delete reservation
        l_rsv_rec.reservation_id := fnd_api.g_miss_num;

	inv_reservation_pub.delete_reservation(
          p_api_version_number		=> 1.0
	, p_init_msg_lst		=> fnd_api.g_false
	, x_return_status		=> l_return_status
	, x_msg_count			=> x_msg_count
	, x_msg_data			=> x_msg_data
	, p_rsv_rec	                => l_rsv_rec
        , p_serial_number		=> l_serial_number);

        if (l_return_status = fnd_api.g_ret_sts_success) then
           x_return_status := l_return_status;

           if (p_form_mode in ('N','n')) then
           	-- kgm_msg
           	fnd_message.set_name('INV', 'INV_RSV_INTERFACE_SUCCESS');
           	fnd_message.set_token('INTERFACE_ID',
           		to_char(p_reservation_interface_id));
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
           	fnd_file.put_line(fnd_file.log,' ');

		/*
           	fnd_message.set_name('INV', 'RSV_INTERFACE_SUCCESS');
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
	   	fnd_file.put(fnd_file.log, 'Reservation Interface Id: ');
	   	fnd_file.put_line(fnd_file.log,
                             to_char(p_reservation_interface_id));
           	fnd_file.put_line(fnd_file.log,' ');
		*/
	   end if;

        elsif (l_return_status = fnd_api.g_ret_sts_error) then
	   raise fnd_api.g_exc_error;
        elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
	   raise fnd_api.g_exc_unexpected_error;
        end if;

  elsif (l_reservation_action_code = 4) then
	-- Transfer reservation

        l_rsv_rec.reservation_id    := fnd_api.g_miss_num;

	inv_reservation_pub.transfer_reservation(
          p_api_version_number		=> 1.0
	, p_init_msg_lst		=> fnd_api.g_false
	, x_return_status		=> l_return_status
	, x_msg_count			=> x_msg_count
	, x_msg_data			=> x_msg_data
        , p_is_transfer_supply        	=> fnd_api.g_true
	, p_original_rsv_rec		=> l_rsv_rec
	, p_to_rsv_rec			=> l_to_rsv_rec
	, p_original_serial_number	=> l_serial_number
	, p_to_serial_number		=> l_serial_number
	, p_validation_flag		=> fnd_api.g_true
	, x_to_reservation_id		=> l_reservation_id);

        if (l_return_status = fnd_api.g_ret_sts_success) then
           x_return_status := l_return_status;

           if (p_form_mode in ('N','n')) then
           	-- kgm_msg
           	fnd_message.set_name('INV', 'INV_RSV_INTERFACE_SUCCESS');
           	fnd_message.set_token('INTERFACE_ID',
           		to_char(p_reservation_interface_id));
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
           	fnd_file.put_line(fnd_file.log,' ');

		/*
           	fnd_message.set_name('INV', 'RSV_INTERFACE_SUCCESS');
           	fnd_file.put_line(fnd_file.log,fnd_message.get);
	   	fnd_file.put(fnd_file.log, 'Reservation Interface Id: ');
	   	fnd_file.put_line(fnd_file.log,
                             to_char(p_reservation_interface_id));
           	fnd_file.put_line(fnd_file.log,' ');
		*/
           end if;

        elsif (l_return_status = fnd_api.g_ret_sts_error) then
	   raise fnd_api.g_exc_error;
        elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
	   raise fnd_api.g_exc_unexpected_error;
        end if;

  else
	-- Invalid or unsuitable action code here

        raise INVALID_ACTION_CODE;

  end if;

  if (l_return_status = fnd_api.g_ret_sts_success) then
      update mtl_reservations_interface
      set row_status_code = 2 /* Completed */
      where reservation_interface_id = p_reservation_interface_id;
  end if;

  exception
    when NO_DATA_FOUND then
      x_return_status := fnd_api.g_ret_sts_error;

      -- kgm_msg
      if (p_form_mode in ('N','n')) then
      	fnd_message.set_name('INV', 'INV_RSV_INTERFACE_ERROR');
      	fnd_message.set_token('INTERFACE_ID',
      		to_char(p_reservation_interface_id));
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      end if;

      -- Add message to message list
      fnd_message.set_name('INV', 'INV_RSV_INTERFACE_NOT_FOUND');
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(
        p_count   => x_msg_count
      , p_data    => x_msg_data
      , p_encoded => 'F');

      -- Load error code and text
      x_error_code := 1;
      x_error_text := fnd_msg_pub.get(1, 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(x_msg_count);
      end if;

    when INVALID_ACTION_CODE then
      x_return_status := fnd_api.g_ret_sts_error;

      if (p_form_mode in ('N','n')) then
      	-- kgm_msg
      	fnd_message.set_name('INV', 'INV_RSV_INTERFACE_ERROR');
        fnd_message.set_token('INTERFACE_ID',
        	to_char(p_reservation_interface_id));
      	fnd_file.put_line(fnd_file.log,fnd_message.get);
      end if;

      -- Add message to message list
      fnd_message.set_name('INV', 'INV_RSV_INTERFACE_INVALID_CODE');
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(
        p_count   => x_msg_count
      , p_data    => x_msg_data
      , p_encoded => 'F');

      -- Load error code and text
      x_error_code := 1;
      x_error_text := fnd_msg_pub.get(1, 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(x_msg_count);
      end if;

    when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error;

      if (p_form_mode in ('N','n')) then
      	-- kgm_msg
      	fnd_message.set_name('INV', 'INV_RSV_INTERFACE_ERROR');
      	fnd_message.set_token('INTERFACE_ID',
      		to_char(p_reservation_interface_id));
      	fnd_file.put_line(fnd_file.log,fnd_message.get);
      end if;

      fnd_msg_pub.count_and_get(
        p_count   => x_msg_count
      , p_data    => x_msg_data
      , p_encoded => 'F');

      -- Load error code and text
      x_error_code := 1;
      x_error_text := fnd_msg_pub.get(1, 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(x_msg_count);
      end if;

    when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      if (p_form_mode in ('N','n')) then
      	-- kgm_msg
      	fnd_message.set_name('INV', 'INV_RSV_INTERFACE_ERROR');
      	fnd_message.set_token('INTERFACE_ID',
      		to_char(p_reservation_interface_id));
      	fnd_file.put_line(fnd_file.log,fnd_message.get);
      end if;

      fnd_msg_pub.count_and_get(
        p_count   => x_msg_count
      , p_data    => x_msg_data
      , p_encoded => 'F');

      -- Load error code and text
      x_error_code := 1;
      x_error_text := fnd_msg_pub.get(1, 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(x_msg_count);
      end if;

    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      if (p_form_mode in ('N','n')) then
      	-- kgm_msg
      	fnd_message.set_name('INV', 'INV_RSV_INTERFACE_ERROR');
      	fnd_message.set_token('INTERFACE_ID',
      		to_char(p_reservation_interface_id));
      	fnd_file.put_line(fnd_file.log,fnd_message.get);
      end if;

      if (fnd_msg_pub.check_msg_level
         (fnd_msg_pub.g_msg_lvl_unexp_error))then
         fnd_msg_pub.add_exc_msg(g_pkg_name,c_api_name);
      end if;

      fnd_msg_pub.count_and_get(
        p_count   => x_msg_count
      , p_data    => x_msg_data
      , p_encoded => 'F');

      -- Load error code and text
      x_error_code := 1;
      x_error_text := fnd_msg_pub.get(1, 'F');

      if (p_form_mode in ('N','n')) then
      	print_error(x_msg_count);
      end if;

end rsv_interface_line_processor;

/*
** ===========================================================================
** Procedure:
**	print_error
**
** Description:
** 	Writes message text in log files.
**
** Input Parameters:
**	p_msg_count
**
** Output Parameters:
**	None
**
** Tables Used:
** 	None
**
** ===========================================================================
*/
PROCEDURE print_error (p_msg_count IN NUMBER)
is
  l_msg_data  VARCHAR2(2000);
begin
  if p_msg_count = 0 then
	null;
  else
	for i in 1..p_msg_count loop
		l_msg_data := fnd_msg_pub.get(i, 'F');
	        fnd_file.put_line(fnd_file.log, l_msg_data);
	end loop;

	fnd_file.put_line(fnd_file.log, ' ');
  end if;

  fnd_msg_pub.initialize;

  exception
    when others then
      	fnd_file.put_line(fnd_file.log, sqlerrm);
end print_error;

END INV_RESERVATIONS_INTERFACE;

/
