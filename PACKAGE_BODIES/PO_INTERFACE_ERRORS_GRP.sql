--------------------------------------------------------
--  DDL for Package Body PO_INTERFACE_ERRORS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INTERFACE_ERRORS_GRP" AS
/* $Header: POXGPIEB.pls 115.2 2003/08/27 18:12:23 bao noship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_INTERFACE_ERRORS_GRP';

-----------------------------------------------------------------------
--Start of Comments
--Name: log_error
--Pre-reqs:
--Modifies: po_interface_errors
--Locks:
--  None
--Function: Insert a record into po_interface_errors table based on
--          the values in record p_rec, which is passed in as a parameter
--Parameters:
--IN:
--p_api_version
--  API Version the caller thinks this API is on
--p_init_msg_list
--  Whether the message stack should get initialized within the procedure
--p_rec
--  A record structure of the table PO_INTERFACE_ERRORS. The values in
--  this record will be inserted into po_interface_errors as a record.
--  See Notes for its usage
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure (FND_API.G_RET_STS_SUCCESS indicates a success,
--  otherwise there is an error occurred)
--x_msg_count
--  Number of messages in the stack
--x_msg_data
--  If x_msg_count is 1, this out parameter will be populated with that msg
--x_row_id
--  rowid of the record that just gets inserted
--Returns:
--Notes:
--  *** This is an autonomous procedure ***
--  Before calling this procedure, p_rec must be populated with values for
--  the columns user wants to set. If p_rec.interface_type is not set, the
--  value 'UNKNOWN' will be populated as INTERFACE_TYPE in po_interface_erros.
--  If p_rec.interface_transaction_id is not set, the value will be derived
--  from the next number in PO_INTERFACE_ERRORS_S sequence.
--  Also, the following fields will be derived within the procedure and
--  the corresponding columns within p_rec will be ignored:
--    creation_date
--    created_by
--    last_update_date
--    last_updated_by
--    last_update_login
--    request_id
--    program_application_id
--    program_id
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE log_error
( p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_rec           IN         PO_INTERFACE_ERRORS%ROWTYPE,
  x_row_id        OUT NOCOPY ROWID
) IS

PRAGMA AUTONOMOUS_TRANSACTION;

l_api_name CONSTANT VARCHAR2(30) := 'log_error';
l_api_version NUMBER := 1.0;

l_progress VARCHAR2(3);

BEGIN

    l_progress := '000';
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '010';

    PO_INTERFACE_ERRORS_PVT.insert_row
    ( p_api_version   => 1.0,
      p_init_msg_list => FND_API.G_FALSE,
      p_commit        => FND_API.G_FALSE,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rec           => p_rec,
      x_row_id        => x_row_id
    );

    l_progress := '020';

    COMMIT;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name       => G_PKG_NAME,
      p_procedure_name => l_api_name || '.' || l_progress
    );

    FND_MSG_PUB.count_and_get
    ( p_encoded => 'F',
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END log_error;

END PO_INTERFACE_ERRORS_GRP;

/
