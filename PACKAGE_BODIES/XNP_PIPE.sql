--------------------------------------------------------
--  DDL for Package Body XNP_PIPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_PIPE" AS
/* $Header: XNPPIPEB.pls 120.2 2006/02/13 07:53:51 dputhiye ship $ */

/* Reads from the specified pipe */

procedure read( p_pipe_name in varchar2
	,x_msg_text OUT NOCOPY varchar2
	,x_error_code OUT NOCOPY number
	,x_error_message OUT NOCOPY varchar2,
	p_timeout in number default 0 )

is
	l_msg_status  number ;

begin

	x_error_code := 0 ;
	x_error_message := 'No Errors' ;

	l_msg_status := dbms_pipe.receive_message(p_pipe_name, p_timeout) ;

	if (l_msg_status = 0) then
		dbms_pipe.unpack_message(x_msg_text) ;
	elsif (l_msg_status = 1) then
		x_error_code := xnp_errors.g_no_msg_in_pipe ;
		x_error_message := 'No message in pipe - timedout' ;
		--We donot use this message for anything - fnd_message.get is a DB call!!
		--fnd_message.set_name('XNP','NO_MSG_IN_PIPE') ;
		--fnd_message.set_token('NAME',p_pipe_name) ;
		--fnd_message.set_token('TIMEOUT',TO_CHAR(p_timeout)) ;
		--x_error_message := fnd_message.get;
	else
		x_error_code := sqlcode ;
		x_error_message := sqlerrm ;
	end if ;

	exception
		when others then
			x_error_code := sqlcode ;
			x_error_message := sqlerrm ;

end read ;


/* Writes to the specified pipe */

procedure write( p_pipe_name in varchar2
	,P_MSG_TEXT IN VARCHAR2
	,x_error_code OUT NOCOPY number
	,x_error_message OUT NOCOPY varchar2
	,p_timeout in number default 0 )
IS

	l_status number ;

begin

	x_error_code := 0 ;
	x_error_message := 'No Errors' ;

	dbms_pipe.purge(p_pipe_name) ;

	dbms_pipe.pack_message(p_msg_text) ;

	l_status := dbms_pipe.send_message(p_pipe_name, p_timeout) ;

	if (l_status <> 0) then
		x_error_code := xnp_errors.g_pipe_write_failure ;
		x_error_message := 'Failed to write to the specified pipe';
	end if ;

	exception
		when others then
			x_error_code := sqlcode ;
			x_error_message := sqlerrm ;

end write ;

end xnp_pipe ;

/
