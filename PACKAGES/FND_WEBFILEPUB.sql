--------------------------------------------------------
--  DDL for Package FND_WEBFILEPUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WEBFILEPUB" AUTHID DEFINER as
/* $Header: AFCPWFPS.pls 120.2 2005/08/20 20:34:30 pferguso ship $ */

procedure verify_id(	id	IN varchar2,
			name 	IN OUT NOCOPY varchar2,
                        node 	IN OUT NOCOPY varchar2);

procedure verify_id(	id	IN varchar2,
			name 	IN OUT NOCOPY varchar2,
                        node 	IN OUT NOCOPY varchar2,
			type    IN OUT NOCOPY varchar2,
			x_mode  IN OUT NOCOPY varchar2);

procedure verify_id(	id	IN varchar2,
			name 	IN OUT NOCOPY varchar2,
                        node 	IN OUT NOCOPY varchar2,
			type    IN OUT NOCOPY varchar2,
			x_mode  IN OUT NOCOPY varchar2,
			req_id  IN OUT NOCOPY varchar2);

procedure verify_id(	id	IN varchar2,
			name 	IN OUT NOCOPY varchar2,
                        node 	IN OUT NOCOPY varchar2,
			type    IN OUT NOCOPY varchar2,
			x_mode  IN OUT NOCOPY varchar2,
			req_id  IN OUT NOCOPY varchar2,
                        dest_file IN OUT NOCOPY varchar2,
                        dest_node IN OUT NOCOPY varchar2,
                        tran_type IN OUT NOCOPY varchar2,
			svc_prefix IN OUT NOCOPY varchar2);

procedure char_mapping( charset IN OUT NOCOPY varchar2);

procedure req_outfile_name( id  IN varchar2,
                            outfile_name IN OUT NOCOPY varchar2);

procedure req_nls_values( nlslang IN OUT NOCOPY varchar2,
                          nlsterr IN OUT NOCOPY varchar2);

procedure check_id( id         IN     varchar2,
                    name       IN OUT NOCOPY varchar2,
                    node       IN OUT NOCOPY varchar2,
                    type       IN OUT NOCOPY varchar2,
                    x_mode     IN OUT NOCOPY varchar2,
                    req_id     IN OUT NOCOPY varchar2,
                    dest_file  IN OUT NOCOPY varchar2,
                    dest_node  IN OUT NOCOPY varchar2,
                    tran_type  IN OUT NOCOPY varchar2,
                    svc_prefix IN OUT NOCOPY varchar2,
                    ncenc      IN OUT NOCOPY varchar2);

procedure check_id( id         IN     varchar2,
                    name       IN OUT NOCOPY varchar2,
                    node       IN OUT NOCOPY varchar2,
                    type       IN OUT NOCOPY varchar2,
                    x_mode     IN OUT NOCOPY varchar2,
                    req_id     IN OUT NOCOPY varchar2,
                    dest_file  IN OUT NOCOPY varchar2,
                    dest_node  IN OUT NOCOPY varchar2,
                    tran_type  IN OUT NOCOPY varchar2,
                    svc_prefix IN OUT NOCOPY varchar2,
                    ncenc      IN OUT NOCOPY varchar2,
		    enable_log IN OUT NOCOPY varchar2);

-- overloaded procedure for 11.0 compatibility
procedure check_id( id         IN     varchar2,
                    name       IN OUT NOCOPY varchar2,
                    node       IN OUT NOCOPY varchar2,
                    type       IN OUT NOCOPY varchar2,
                    x_mode     IN OUT NOCOPY varchar2,
                    req_id     IN OUT NOCOPY varchar2);


procedure get_page_info(	id	     IN varchar2,
			                name 	 IN OUT NOCOPY varchar2,
			                pagenum  IN OUT NOCOPY number,
			                pagesize IN OUT NOCOPY number);

end;

 

/

  GRANT EXECUTE ON "APPS"."FND_WEBFILEPUB" TO "APPLSYSPUB";
