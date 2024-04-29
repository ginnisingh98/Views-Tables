--------------------------------------------------------
--  DDL for Package Body PO_MASS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MASS_UPDATE" AS
/* $Header: POXMUB1B.pls 120.2.12010000.2 2009/06/20 00:30:33 yuewliu ship $ */


/*================================================================

  PROCEDURE NAME: 	po_update_buyer()

==================================================================*/

PROCEDURE po_update_buyer(x_old_buyer_id  IN NUMBER,
                          x_new_buyer_id  IN NUMBER,
                          x_commit_intrl  IN NUMBER) is

/* Bug#2718220 Added the REJECTED status also so that the Program will update
** all the Documents with REJECTED also apart from APPROVED,REQUIRES REAPPROVAL
** and INCOMPLETE statuses.
*/

cursor c_po is
select poh.rowid,
       poh.segment1,
       pdt.type_name,
       poh.po_header_id,                 --<CONTERMS FPJ>
       poh.type_lookup_code,             --<CONTERMS FPJ>
       poh.revision_num,                 --<CONTERMS FPJ>
       NVL(poh.conterms_exist_flag, 'N') --<CONTERMS FPJ>
from po_headers poh,
     po_document_types_vl pdt
where poh.agent_id = x_old_buyer_id
and   nvl(poh.authorization_status,'INCOMPLETE') in ('APPROVED','REQUIRES REAPPROVAL','INCOMPLETE','REJECTED')
and nvl(poh.closed_code,'OPEN') not in ('CLOSED','FINALLY CLOSED')
and nvl(poh.cancel_flag,'N') = 'N'
and nvl(poh.frozen_flag,'N') = 'N'
and pdt.document_type_code in ('PO','PA')
and pdt.document_subtype = poh.type_lookup_code
order by poh.segment1;

/* Bug#2718220 Added the REJECTED status also so that the Program will update
** all the Documents with REJECTED also apart from APPROVED,REQUIRES REAPPROVAL
** and INCOMPLETE statuses.
*/

cursor c_rel is
select por.rowid,
       poh.segment1,
       por.release_num,
       pdt.type_name,
       por.po_release_id--8551445
from po_releases por,
     po_headers poh,
     po_document_types_vl pdt
where por.po_header_id = poh.po_header_id
and por.agent_id = x_old_buyer_id
and nvl(por.authorization_status,'INCOMPLETE') in ('APPROVED','REQUIRES REAPPROVAL','INCOMPLETE','REJECTED')
and nvl(por.closed_code,'OPEN') not in ('CLOSED','FINALLY CLOSED')
and nvl(por.cancel_flag,'N') = 'N'
and nvl(por.frozen_flag,'N') = 'N'
and pdt.document_type_code ='RELEASE'
and pdt.document_subtype = por.release_type
order by poh.segment1,por.release_num;

x_po_rowid         ROWID;
x_rel_rowid        ROWID;
x_doc_type         po_document_types_all.type_name%TYPE;
x_po_num           po_headers.segment1%TYPE;
x_rel_num          po_releases.release_num%TYPE;
x_old_buyer_name   varchar2(240);
x_new_buyer_name   varchar2(240);
x_org_id           number;

/** <UTF8 FPI> **/
/** tpoon 9/27/2002 **/
/** Changed x_org_name to use %TYPE **/
-- x_org_name         varchar2(60);
x_org_name         hr_all_organization_units.name%TYPE;

x_po_count         number := 0;
x_rel_count        number := 0;
x_progress         varchar2(3) := null;

x_msg1             varchar2(240);
x_msg2             varchar2(240);
x_msg3             varchar2(240);
x_msg4             varchar2(240);
x_msg5             varchar2(240);
x_msg6             varchar2(240);
x_msg7             varchar2(240);
x_msg8             varchar2(240);

/* CONTERMS FPJ */
l_api_name VARCHAR2(30) := 'po_update_buyer';

l_document_id po_headers.po_header_id%TYPE;
l_document_type po_headers.type_lookup_code%TYPE;
l_document_version po_headers.revision_num%TYPE;
l_conterms_exist_flag po_headers.conterms_exist_flag%TYPE;

-- contracts dependency
l_contracts_document_type VARCHAR2(150);
SUBTYPE busdocs_tbl_type IS okc_manage_deliverables_grp.busdocs_tbl_type;
l_busdocs_tbl busdocs_tbl_type;
l_empty_busdocs_tbl busdocs_tbl_type; --empty table for resetting.

l_row_index PLS_INTEGER := 0; --separate row count for POs with conterms

-- out parameters for the contracts group API
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
/* CONTERMS FPJ */

BEGIN

  x_progress := '000';
 /* Get the full names of the buyers */

/* Bug#2571620 Modified the below code by commenting out and added a correct
** procedure call as get_employee_name() is not retrieving the Terminated
** Buyer names,which is wrong.
** PO_EMPLOYEES_SV.get_employee_name(x_old_buyer_id, x_old_buyer_name);
*/
    x_old_buyer_name := PO_EMPLOYEES_SV.get_emp_name(x_old_buyer_id);
    PO_EMPLOYEES_SV.get_employee_name(x_new_buyer_id, x_new_buyer_name);

 /* get the current operating unit */
  x_progress := '001';

    select org_id
    into x_org_id
    from po_system_parameters;
--If condition added by jbalakri for bug 2374299
 if x_org_id is not null then
    select hou.name
    into x_org_name
    from hr_all_organization_units hou,
         hr_all_organization_units_tl hout
    where hou.organization_id = hout.organization_id
    and hout.language = userenv('LANG')
    and hou.organization_id = x_org_id;
 end if;
-- end of code for 2374299
 /* Get the messages needed to print the headers */
     fnd_message.set_name('PO','PO_MUB_MSG_HEADER1');
     x_msg1 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DATE');
     x_msg2 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_OU');
     x_msg3 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_OLD_BUYER');
     x_msg4 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_NEW_BUYER');
     x_msg5 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_HEADER2');
     fnd_message.set_token('OLD_BUYER',x_old_buyer_name);
     fnd_message.set_token('NEW_BUYER',x_new_buyer_name);
     x_msg6 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_NUM');
     x_msg7 := fnd_message.get;

     fnd_message.set_name('PO','PO_MUB_MSG_DOC_TYPE');
     x_msg8 := fnd_message.get;


 /* Print the common header */
 /*The output will be of the following format  :  */
 /*--------------------------------------------------------------*
  *                                                              *
  *     Mass Update of Buyer Name on Purchasing Documents Report *
  *                                                              *
  *   DATE                   :  DD-MON-YYYY                      *
  *   OPERATING UNIT         :  Vision Operations                *
  *   OLD BUYER              :  Green, Terry                     *
  *   NEW BUYER              :  Stock, Pat                       *
  *                                                              *
  *  The Buyer was updated on the following Documents.           *
  *  Document Number        Document Type                        *
  *  ------------------------------------------------            *
  *  1234                   Standard Purchase Order              *
  *  1222                   Blanket Agreement                    *
  *  1222-1                 Blanket Release                      *
  *  .....                  ......                               *
  *--------------------------------------------------------------*/

     fnd_file.put_line(fnd_file.output, x_msg1);
     fnd_file.put_line(fnd_file.output, '                         ');

     fnd_file.put_line(fnd_file.output, rpad(x_msg2,21) || ' : ' || sysdate);
     fnd_file.put_line(fnd_file.output, rpad(x_msg3,21) || ' : ' || x_org_name);
     fnd_file.put_line(fnd_file.output, rpad(x_msg4,21) || ' : ' || x_old_buyer_name);
     fnd_file.put_line(fnd_file.output, rpad(x_msg5,21) || ' : ' || x_new_buyer_name);
     fnd_file.put_line(fnd_file.output, '                                         ');


     fnd_file.put_line(fnd_file.output, x_msg6);
     fnd_file.put_line(fnd_file.output, '                                                      ');

     fnd_file.put_line(fnd_file.output,  rpad(x_msg7,26) || x_msg8);
     fnd_file.put_line(fnd_file.output,  rpad('-',60,'-'));

 /* open the PO cursur */
    x_progress := '002';

    OPEN c_po;

    LOOP
     FETCH c_po into x_po_rowid,
                     x_po_num,
                     x_doc_type,
                     l_document_id,        --<CONTERMS FPJ>
                     l_document_type,      --<CONTERMS FPJ>
                     l_document_version,   --<CONTERMS FPJ>
                     l_conterms_exist_flag;--<CONTERMS FPJ>
     EXIT when c_po%notfound;

 /* Update all the fetched PO documents with the new buyer */
    x_progress := '003';

/* Bug#3082301 Added the WHO columns to the below update statement so that
** Mass Update Buyer Name Program will update the WHO columns also on all
** Purchasing Documents(POs) which are effected by the program.
*/
         update po_headers_all
         set agent_id = x_new_buyer_id,
             last_update_date  = sysdate,
             last_updated_by   = fnd_global.user_id,
             last_update_login = fnd_global.login_id
         where rowid = x_po_rowid;

  --Bug 8551445, update archive also.

  BEGIN
         UPDATE po_headers_archive_all
         SET  agent_id = x_new_buyer_id,
              last_update_date  = sysdate,
             last_updated_by   = fnd_global.user_id,
             last_update_login = fnd_global.login_id
         WHERE po_header_id=l_document_id
         AND   latest_external_flag= 'Y';
  EXCEPTION
         WHEN NO_DATA_FOUND THEN
         NULL;
  END;

  --Bug 8551445 end.

  /* Based on the commit interval passed by the user we commit after that many records
     and reset the counter */
     x_progress := '004';

         x_po_count := x_po_count + 1;

           /* CONTERMS FPJ START */
           -- save the document id, type and version in the table for contracts purge
	   -- if conterms exist
	   IF (UPPER(l_conterms_exist_flag)='Y') THEN

	     -- increment the row index
	     l_row_index := l_row_index + 1;

             l_busdocs_tbl(l_row_index).bus_doc_id := l_document_id;
             l_busdocs_tbl(l_row_index).bus_doc_version := l_document_version;

             IF (l_document_type IN ('BLANKET', 'CONTRACT')) THEN
               l_contracts_document_type := 'PA_'||l_document_type;
             ELSIF (l_document_type = 'STANDARD') THEN
               l_contracts_document_type := 'PO_'||l_document_type;
             END IF;
             l_busdocs_tbl(l_row_index).bus_doc_type := l_contracts_document_type;
	   END IF; -- conterms exist
	   /* CONTERMS FPJ END */

           if x_po_count = x_commit_intrl then
	       /* CONTERMS FPJ START*/
               -- check if there are any values in the table before calling the API
	       IF (l_busdocs_tbl.COUNT >= 1) THEN

               x_progress := '005';

               okc_manage_deliverables_grp.updateIntContactOnDeliverables (
                   p_api_version                  => 1.0,
                   p_init_msg_list                => FND_API.G_FALSE,
                   p_commit                       => FND_API.G_FALSE,
                   p_bus_docs_tbl                 => l_busdocs_tbl,
                   p_original_internal_contact_id => x_old_buyer_id,
                   p_new_internal_contact_id      => x_new_buyer_id,
                   x_msg_data                     => l_msg_data,
                   x_msg_count                    => l_msg_count,
                   x_return_status                => l_return_status);

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 -- get message to log and raise error
                 FND_MSG_PUB.Count_and_Get(p_count => l_msg_count
                                          ,p_data  => l_msg_data);
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

	       END IF;
               /* CONTERMS FPJ END */

	     -- commit and reset variables for the next batch
	     commit;
             x_po_count := 0;

	     /* CONTERMS FPJ START */
             -- reset table and the count
             l_busdocs_tbl := l_empty_busdocs_tbl;
	     l_row_index := 0;
             /* CONTERMS FPJ END */
         end if;


         /* Print the document number and type */
         fnd_file.put_line(fnd_file.output, rpad(x_po_num,26) ||  x_doc_type );

    END LOOP;
  CLOSE c_po;

  /* CONTERMS FPJ START */
  -- if number of POs selected is less than commit interval at any time
  -- call the purge API again for the remaining POs
  -- check if there are any values in the table before calling the API
  IF (l_busdocs_tbl.COUNT >= 1) THEN

     okc_manage_deliverables_grp.updateIntContactOnDeliverables (
                   p_api_version                  => 1.0,
                   p_init_msg_list                => FND_API.G_FALSE,
                   p_commit                       => FND_API.G_FALSE,
                   p_bus_docs_tbl                 => l_busdocs_tbl,
                   p_original_internal_contact_id => x_old_buyer_id,
                   p_new_internal_contact_id      => x_new_buyer_id,
                   x_msg_data                     => l_msg_data,
                   x_msg_count                    => l_msg_count,
                   x_return_status                => l_return_status);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        -- get message to log and raise error
        FND_MSG_PUB.Count_and_Get(p_count => l_msg_count
                                 ,p_data  => l_msg_data);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;
  /* CONTERMS FPJ END */



  /* open the PO Release cursur */
   x_progress := '005';

  OPEN c_rel;
    LOOP

     FETCH c_rel into x_rel_rowid,
                     x_po_num,
                     x_rel_num,
                     x_doc_type,
                     l_document_id; --Bug 8551445
     EXIT when c_rel%notfound;


  /* Update all the fetched PO Release documents with the new buyer */
     x_progress := '006';

/* Bug#3082301 Added the WHO columns to the below update statement so that
** Mass Update Buyer Name Program will update the WHO columns also on all
** Purchasing Documents(Releases) which are effected by the program.
*/
         update po_releases_all
         set agent_id = x_new_buyer_id,
             last_update_date  = sysdate,
             last_updated_by   = fnd_global.user_id,
             last_update_login = fnd_global.login_id
         where rowid = x_rel_rowid;

   --Bug 8551445, update archive also.
    BEGIN
         UPDATE po_releases_archive_all
         SET  agent_id = x_new_buyer_id,
              last_update_date  = sysdate,
             last_updated_by   = fnd_global.user_id,
             last_update_login = fnd_global.login_id
         WHERE po_release_id=l_document_id
         AND   latest_external_flag= 'Y';

    EXCEPTION
         WHEN NO_DATA_FOUND THEN
         NULL;
    END;
    --Bug 8551445 end.

  /* Based on the commit interval passed by the user we commit after that many records
     and reset the counter */
     x_progress := '007';

         x_rel_count := x_rel_count + 1;
         if x_rel_count = x_commit_intrl then
          commit;
          x_rel_count := 0;
         end if;

   /* Print the document number and type */
         fnd_file.put_line(fnd_file.output, rpad(x_po_num || '-' || x_rel_num,26) ||  x_doc_type);

    END LOOP;
  CLOSE c_rel;

  x_progress := '008';

  -- <CONTERMS FPJ>
  -- needs a commit for number of POs that are less than commit interval
  COMMIT;

EXCEPTION
    /* CONTERMS FPJ START */
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
             IF (g_fnd_debug='Y') THEN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                 FND_LOG.string(log_level => FND_LOG.level_unexpected
                             ,module    => g_module_prefix ||l_api_name
                             ,message   => l_msg_data);
               END IF;
         END IF;
     END IF;
    /* CONTERMS FPJ END */

    WHEN others THEN
         po_message_s.sql_error('po_update_buyer', x_progress, sqlcode);
         raise;
END;

END PO_MASS_UPDATE;

/
