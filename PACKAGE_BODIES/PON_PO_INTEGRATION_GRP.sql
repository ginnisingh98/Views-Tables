--------------------------------------------------------
--  DDL for Package Body PON_PO_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_PO_INTEGRATION_GRP" AS
/* $Header: PONGPOIB.pls 120.2 2006/03/24 09:38:32 smhanda noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'PON_PO_INTEGRATION_GRP';

-----------------------------------------------------------------------
--Start of Comments
--Name: validate_po_purge
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function:
--  Given the header ids of PO documents, determine whether they are allowed
--  to be purged from PON's perspective
--Parameters:
--IN:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--p_commit
--  FND_API.G_TRUE: procedure should commit
--  FND_API.G_FALSE: procedure should not commit
--p_in_rec
--  A structure that holds PO information
--  p_in_rec.entity_name will expect 'PO_HEADERS', while p_in_rec.entity_ids
--  will be a table of all document header ids that PO are about to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_count
--  Number of messages in message stack
--x_msg_data
--  If there is only 1 message in message stack, this out variable should
--  be populated with that message
--x_out_rec
--  A structure indicating whether PO documents can be purged or not
--  For each entry in p_in_rec.entity_ids, the corresponding entry in
--  x_out_rec.purge_allowed will indicate whether the document is purgable
--  or not. e.g., If x_out_rec.purge_allowed(i) is 'Y', it means that
--  p_in_rec.entity_ids(i) can be purged. If x_out_rec.purge_allowed(i) is 'N',
--  the document specified in p_in_rec.entity_ids(i) will not be purged.
--  The number of records in x_out_rec.purge_allowed should always be the
--  same as that for p_in_rec.entity_ids
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE validate_po_purge
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_in_rec        IN         PURGE_IN_RECTYPE,
  x_out_rec       OUT NOCOPY PURGE_OUT_RECTYPE
) IS

  l_api_version NUMBER := 1.0;
  l_api_name    VARCHAR2(50) := 'validate_po_purge';
  l_progress    NUMBER;
  l_idx         NUMBER;
  l_references  NUMBER;

BEGIN
  -- initialize return for unexpected error
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  l_progress := 100;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := 150;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  l_progress := 200;

  if (p_in_rec.entity_name = 'PO_HEADERS') then
    for l_idx in 1..p_in_rec.entity_ids.count loop
     begin
      select  1
      into l_references
      from dual
      where exists (select 1
                    from pon_bid_headers
                    where po_header_id = p_in_rec.entity_ids(l_idx)
		    );
      exception  when no_data_found then
         l_references := 0;
     end;
      l_progress := 300;

      if (l_references = 0) then
      begin
        select  1
        into l_references
	from dual
	where exists ( select 1
                       from pon_auction_headers_all
                       where source_doc_msg in ('PO_POTYPE_BLKT', 'PO_POTYPE_CNTR')
                       and source_doc_id = p_in_rec.entity_ids(l_idx)
		      );
      exception when no_data_found then
         l_references := 0;
     end;

        l_progress := 400;

        if (l_references = 0) then
	  x_out_rec.purge_allowed(l_idx) := 'Y';
        else
          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                           'pon.pon_po_integration_grp',
                           'po_header ' || p_in_rec.entity_ids(l_idx) || ' failed in pon_auction_headers_all');
          end if;

          x_out_rec.purge_allowed(l_idx) := 'N';
        end if;
      else
        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_statement,
                         'pon.pon_po_integration_grp',
                         'po_header ' || p_in_rec.entity_ids(l_idx) || ' failed in pon_bid_headers');
        end if;

	x_out_rec.purge_allowed(l_idx) := 'N';
      end if;
    end loop;
  else -- p_in_rec.entity_name = 'PO_REQUISITION_HEADERS'
    for l_idx in 1..p_in_rec.entity_ids.count loop
     begin
      select 1
      into l_references
      from dual
      where exists ( select 1
                     from pon_backing_requisitions
                     where requisition_header_id = p_in_rec.entity_ids(l_idx)
		    );
      exception when no_data_found then
         l_references := 0;
     end;

      l_progress := 350;

      if (l_references = 0) then
        x_out_rec.purge_allowed(l_idx) := 'Y';
      else
        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_statement,
                         'pon.pon_po_integration_grp',
                         'po_requisition_headers ' || p_in_rec.entity_ids(l_idx) || ' pon_backing_requisitions');
        end if;

        x_out_rec.purge_allowed(l_idx) := 'N';
      end if;
    end loop;
  end if; -- entity_name

  l_progress := 500;

  if (p_commit = fnd_api.g_true) then
    commit;
  end if;

  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;
  x_msg_data := null;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

    FND_MSG_PUB.count_and_get
    ( p_encoded => 'F',
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END validate_po_purge;

-----------------------------------------------------------------------
--Start of Comments
--Name: po_purge
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function:
--  Perform necessary actions for PON records when PO documents are purged
--Parameters:
--IN:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--p_commit
--  FND_API.G_TRUE: procedure should commit
--  FND_API.G_FALSE: procedure should not commit
--p_in_rec
--  A structure that holds PO information
--  p_in_rec.entity_name will expect 'PO_HEADERS', while p_in_rec.entity_ids
--  will be a table of all document header ids that PO are about to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_count
--  Number of messages in message stack
--x_msg_data
--  If there is only 1 message in message stack, this out variable should
--  be populated with that message
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE po_purge
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_in_rec        IN         PURGE_IN_RECTYPE
) IS

  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'po_purge';
  l_progress NUMBER;

BEGIN
  -- initialize return for unexpected error
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  l_progress := 100;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := 150;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  l_progress := 200;

  if (p_commit = fnd_api.g_true) then
    commit;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

    FND_MSG_PUB.count_and_get
    ( p_encoded => 'F',
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END po_purge;

END PON_PO_INTEGRATION_GRP;

/
