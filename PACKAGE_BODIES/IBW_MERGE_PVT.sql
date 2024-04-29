--------------------------------------------------------
--  DDL for Package Body IBW_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_MERGE_PVT" As
/* $Header: ibwvmrgb.pls 120.3 2006/11/06 14:48:53 pakrishn noship $ */


 /*------------------------------------------------------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                                                                                     |
|                  MERGE_PAGES -- 				                                                                                                       |
|			     API  registered to merge, party_id and party_relationship_id in ibw_page_views
|          These API's will be called when party_id in the HZ_parties will be merged.
*--------------------------------------------------------------------------------------------------------------------------*/


PROCEDURE MERGE_PAGES(
			P_entity_name		             IN		VARCHAR2,
			P_from_id			                  IN		NUMBER,
			X_to_id			                        OUT NOCOPY   NUMBER,
			P_from_fk_id		              IN		NUMBER,
			P_to_fk_id			                  IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			                IN		NUMBER,
			P_batch_party_id		        IN		NUMBER,
			X_return_status		          OUT NOCOPY  VARCHAR2
				)  IS

  l_count                 NUMBER(10)   := 0;
  l_message_text   fnd_new_messages.message_text%type;


RESOURCE_BUSY           EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN

    begin
    fnd_message.set_name('IBW','IBW_PARTY_MERGE');
    fnd_message.set_token('DESC','  IBW_PAGE_VIEWS  merge started '  );
    l_message_text := fnd_message.get;
    fnd_file.put_line(FND_FILE.LOG,l_message_text);
    fnd_file.put_line(FND_FILE.OUTPUT,l_message_text);
   end ;

x_return_status :=  FND_API.G_RET_STS_SUCCESS;

/* Perform the merge operation */

/* If the parent has NOT Changed(i.e Parent is getting transfered), then nothing needs to be done. Set Merge To id same
   as Merged from id and return */

   if p_from_fk_id = p_to_fk_id then
		x_to_id := p_from_id;
		return;
   End If;


/* If the Parent has changed(i.e. Parent is getting merged), then transfer the dependent record to the new parent. */

   if p_from_fk_id <> p_to_fk_id Then
    	IF p_parent_entity_name = 'HZ_PARTIES' Then

              begin
                   fnd_message.set_name('IBW','IBW_PARTY_MERGE');
                   fnd_message.set_token('DESC',' Updating  ibw_page_views : Start'  );
                   l_message_text := fnd_message.get;
                   fnd_file.put_line(FND_FILE.LOG,l_message_text);
                   fnd_file.put_line(FND_FILE.OUTPUT,l_message_text);
           end ;

/* The below query would be executed  when PARTY_ID  of type 'ORGANIZATION'  or 'PERSON'   or 'PARTY RELATIONSHIP' is merged
    in HZ_PARTIES Table.
 */

		UPDATE IBW_PAGE_VIEWS SET
				party_id = DECODE(party_id,p_from_fk_id,p_to_fk_id,party_id),
        party_relationship_id =  DECODE(  party_relationship_id,p_from_fk_id,p_to_fk_id,  party_relationship_id),
	visitant_id = case when visitant_id like 'p%' then 'p'||DECODE(party_id,p_from_fk_id,p_to_fk_id,party_id) else visitant_id end, /* Bug 5624186*/
				last_update_date = hz_utility_pub.last_update_date,
				last_updated_by  = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				request_id = hz_utility_pub.request_id,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id
				Where party_id = p_from_fk_id
                    OR party_relationship_id = p_from_fk_id ;

		l_count := sql%rowcount;


      begin
          fnd_message.set_name('IBW','IBW_PARTY_MERGE');
          fnd_message.set_token('DESC',' IBW_PAGE_VIEWS Rows updated :'||to_char(l_count)  );
          l_message_text := fnd_message.get;
          fnd_file.put_line(FND_FILE.LOG,l_message_text);
          fnd_file.put_line(FND_FILE.OUTPUT,l_message_text);
   end ;

		return;
	END IF;
End If;

Exception
	When RESOURCE_BUSY Then
    begin
        fnd_message.set_name('IBW','IBW_PARTY_MERGE');
        fnd_message.set_token('DESC',' IBW_MERGE_PVT.MERGE_PAGES; Could not obtain lock on table IBW_PAGE_VIEWS'  );
        l_message_text := fnd_message.get;
        fnd_file.put_line(FND_FILE.LOG,l_message_text);
    end ;
		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;

	When Others Then

  begin
    fnd_message.set_name('IBW','IBW_PARTY_MERGE');
    fnd_message.set_token('DESC','IBW_MERGE_PVT.MERGE_PAGES : '||sqlerrm  );
    l_message_text := fnd_message.get;
    fnd_file.put_line(FND_FILE.LOG,l_message_text);
   end ;

		x_return_status :=  FND_API.G_RET_STS_ERROR;
  		raise;
END MERGE_PAGES;


 /*------------------------------------------------------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                                                                                     |
|                  MERGE_SITES -- 				                                                                                                         |
|			     API  registered to merge, party_id  in ibw_site_visits
|          These API's will be called when party_id in the HZ_parties will be merged.
*--------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE MERGE_SITES(
			P_entity_name	        	IN		VARCHAR2,
			P_from_id			              IN		NUMBER,
			X_to_id			                    OUT NOCOPY   NUMBER,
			P_from_fk_id		          IN		NUMBER,
			P_to_fk_id			              IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			            IN		NUMBER,
			P_batch_party_id		    IN		NUMBER,
			X_return_status		     OUT NOCOPY  VARCHAR2
				)  IS

l_merge_reason_code 	VARCHAR2(30);
l_count                 NUMBER(10)   := 0;
l_message_text   fnd_new_messages.message_text%type;


RESOURCE_BUSY           EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN

 begin
    fnd_message.set_name('IBW','IBW_PARTY_MERGE');
    fnd_message.set_token('DESC','  IBW_SITE_VISITS  merge started '  );
    l_message_text := fnd_message.get;
    fnd_file.put_line(FND_FILE.LOG,l_message_text);
    fnd_file.put_line(FND_FILE.OUTPUT,l_message_text);
   end ;

x_return_status :=  FND_API.G_RET_STS_SUCCESS;

/* Perform the merge operation */

/* If the parent has NOT Changed(i.e Parent is getting transfered), then nothing needs to be done. Set Merge To id same
   as Merged from id and return */

   if p_from_fk_id = p_to_fk_id then
		x_to_id := p_from_id;
		return;
   End If;


/* If the Parent has changed(i.e. Parent is getting merged), then transfer the dependent record to the new parent. */
   if p_from_fk_id <> p_to_fk_id Then
     	IF p_parent_entity_name = 'HZ_PARTIES' Then

        begin
                   fnd_message.set_name('IBW','IBW_PARTY_MERGE');
                   fnd_message.set_token('DESC',' Updating  ibw_site_visits : Start'  );
                   l_message_text := fnd_message.get;
                   fnd_file.put_line(FND_FILE.LOG,l_message_text);
                   fnd_file.put_line(FND_FILE.OUTPUT,l_message_text);
           end ;

/* The below query would be executed  when PARTY_ID  of type 'ORGANIZATION'  or 'PERSON'   is merged
    in HZ_PARTIES Table.
 */

		UPDATE IBW_SITE_VISITS SET
				party_id = DECODE(party_id,p_from_fk_id,p_to_fk_id,party_id),
				visitant_id = case when visitant_id like 'p%' then 'p'||DECODE(party_id,p_from_fk_id,p_to_fk_id,party_id) else visitant_id end,  /* Bug 5624186*/
        last_update_date = hz_utility_pub.last_update_date,
				last_updated_by  = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				request_id = hz_utility_pub.request_id,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id
				Where party_id = p_from_fk_id	;

		l_count := sql%rowcount;

	begin
          fnd_message.set_name('IBW','IBW_PARTY_MERGE');
          fnd_message.set_token('DESC',' IBW_SITE_VISITS Rows updated :'||to_char(l_count)  );
          l_message_text := fnd_message.get;
          fnd_file.put_line(FND_FILE.LOG,l_message_text);
          fnd_file.put_line(FND_FILE.OUTPUT,l_message_text);
   end ;

		return;
	END IF;
End If;


Exception
	When RESOURCE_BUSY Then
      begin
        fnd_message.set_name('IBW','IBW_PARTY_MERGE');
        fnd_message.set_token('DESC',' IBW_MERGE_PVT.MERGE_SITES; Could not obtain lock on table IBW_SITE_VISITS'  );
        l_message_text := fnd_message.get;
        fnd_file.put_line(FND_FILE.LOG,l_message_text);
    end ;

		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;

	When Others Then

  begin
    fnd_message.set_name('IBW','IBW_PARTY_MERGE');
    fnd_message.set_token('DESC','IBW_MERGE_PVT.MERGE_SITES : '||sqlerrm  );
    l_message_text := fnd_message.get;
    fnd_file.put_line(FND_FILE.LOG,l_message_text);
   end ;
		x_return_status :=  FND_API.G_RET_STS_ERROR;

   begin
     fnd_message.set_name('IBW','IBW_PARTY_MERGE');
     fnd_message.set_token('DESC',' IBW_MERGE_PVT. MERGE_SITESsql error   '  );
     l_message_text := fnd_message.get;
     fnd_file.put_line(FND_FILE.LOG,l_message_text);
     fnd_file.put_line(FND_FILE.OUTPUT,l_message_text);
   end ;
   	raise;

END MERGE_SITES;


END IBW_MERGE_PVT;

/
