--------------------------------------------------------
--  DDL for Package PO_APPROVALLIST_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_APPROVALLIST_S1" AUTHID CURRENT_USER AS
/* $Header: POXAPL1S.pls 120.1.12010000.3 2010/05/04 11:19:41 dashah ship $*/


-- Record to hold the approval list elements
TYPE ApprovalListEltType IS RECORD (
  id                   NUMBER,         -- unique identifier
  sequence_num         NUMBER,         -- sequence number
  approver_id          NUMBER,         -- approver employee id
  approver_disp_name   VARCHAR2(240),  -- approver display name
  responder_id         NUMBER,         -- responder employee id
  responder_disp_name  VARCHAR2(240),  -- responder display name
  forward_to_id        NUMBER,         -- forward-to employee id
  forward_to_disp_name VARCHAR2(240),  -- forward-to display name
  status               VARCHAR2(30),   -- status of approver: APPROVE, FORWARD,
                                       --  APPROVE_AND_FORWARD, REJECT, PENDING,
                                       --  NULL
  response_date        DATE,
  approver_type        VARCHAR2(30),   -- type of approver: SYSTEM, USER, FORWARD
  mandatory_flag       VARCHAR2(1)     -- Y: approver is mandatory
                                       -- N: approver is not mandatory
);


-- Table of ApprovalListEltType records
TYPE ApprovalListType IS TABLE OF ApprovalListEltType INDEX BY BINARY_INTEGER;

-- Record to hold the error stack entries
TYPE ErrorStackEltType IS RECORD (
  message_name     VARCHAR2(30),
  number_of_tokens NUMBER,
  token1           VARCHAR2(30),
  value1           VARCHAR2(300),
  token2           VARCHAR2(30),
  value2           VARCHAR2(300),
  token3           VARCHAR2(30),
  value3           VARCHAR2(300),
  token4           VARCHAR2(30),
  value4           VARCHAR2(300),
  token5           VARCHAR2(30),
  value5           VARCHAR2(300)
);

-- Table of ErrorStackEltType records
TYPE ErrorStackType IS TABLE OF ErrorStackEltType INDEX BY BINARY_INTEGER;

-- Table of ErrorStackEltType records
TYPE MessageStackType IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;

-- Global error codes
E_SUCCESS                      CONSTANT NUMBER := 0;  -- Dont change this one!
                                                      -- forms rely on value 0.
E_LIST_MODIFIED_SINCE_RETRIEVE CONSTANT NUMBER := 1.01;
E_INVALID_LIST_HEADER_ID       CONSTANT NUMBER := 1.02;
E_INVALID_APPROVAL_LIST        CONSTANT NUMBER := 1.03;
E_NO_SUPERVISOR_FOUND          CONSTANT NUMBER := 1.04;
E_NO_ONE_HAS_AUTHORITY         CONSTANT NUMBER := 1.05;
E_FAIL_TO_ACQUIRE_LOCK         CONSTANT NUMBER := 1.06;
E_NO_APPROVAL_LIST_FOUND       CONSTANT NUMBER := 1.07;
E_NO_NEXT_APPROVER_FOUND       CONSTANT NUMBER := 1.08;
E_DOCUMENT_ALREADY_PREAPPROVED CONSTANT NUMBER := 1.09;
E_INVALID_APPROVER             CONSTANT NUMBER := 1.10;
E_FAIL_TO_UPDATE_RESPONSE      CONSTANT NUMBER := 1.11;
E_UNSUPPORTED_DOCUMENT_TYPE    CONSTANT NUMBER := 1.12;
E_INVALID_FORWARD_TO_ID        CONSTANT NUMBER := 1.13;
E_INVALID_DOCUMENT_ID          CONSTANT NUMBER := 1.14;
E_INVALID_REBUILD_CODE         CONSTANT NUMBER := 1.15;
E_INVALID_FIRST_APPROVER_ID    CONSTANT NUMBER := 1.16;
E_EMPTY_APPROVAL_LIST          CONSTANT NUMBER := 1.17;
E_EMPTY_ERROR_STACK            CONSTANT NUMBER := 1.18;
E_DOC_MGR_TIMEOUT              CONSTANT NUMBER := 1.91;
E_DOC_MGR_NOMGR                CONSTANT NUMBER := 1.92;
E_DOC_MGR_OTHER                CONSTANT NUMBER := 1.93;

g_checkout_flow_type   VARCHAR2(30) := '';

-- Description: Retrieve the default approval list needed at the time the
--              requisition is first submitted.
--
-- Arguments:
--   In: p_first_approver_id  ... employee id of first approver [optional]
--       p_approval_path_id   ... approval path id [optional]
--       p_document_id        ... header_id of new document
--       p_document_type      ... document type
--       p_document_subtype   ... document subtype
--  Out: p_return_code        ... E_SUCCESS
--                                  - operation is successful
--                                E_NO_ONE_HAS_AUTHORITY
--                                  - no one has the authority to approve the
--                                    document (NOTE: p_approval_list still
--                                    contains the default approval list)
--                                E_DOC_MGR_TIMEOUT
--                                  - document manager timed out
--                                E_DOC_MGR_NOMGR
--                                  - document manager not available
--                                E_DOC_MGR_OTHER
--                                  - document manager errored out
--                                others
--                                  - a sqlcode in case in case of sql errors
--       p_error_stack        ... a stack of error message codes and tokens
--       p_approval_list      ... default approval list
--
-- Algorithm:
--   (1) Get approval path id, use position flag, can preparer approve flag
--   (2) If preparer can and has authority to approve, return success with
--       empty approval list
--   (3) Get forward method: Direct or Hierarchy
--   (4) Get next approver base on the preparers employee id, position
--       flag and approval path
--   (5) Verify approver's approval authority (** NOTE: This calls the doc
--       manager which has COMMIT and ROLLBACK statements. **)
--   (6) If approver has authority to approve:
--         (a) Add approver to approval list
--         (b) Find out if approver will be on vacation (from wf_route pkg)
--         (c) Goto (7)
--       else (doesn't not have authority):
--         (c) If using Hierarchy forward method: Add approver to list
--                                                Find out vacation info (?)
--             else (using Direct)              : No op
--         (d) Goto (4)
--   (7) Mark all approvers as type System default
--   (8) Return
--
PROCEDURE get_default_approval_list(p_first_approver_id IN     NUMBER,
                                    p_approval_path_id  IN     NUMBER,
                                    p_document_id       IN     NUMBER,
                                    p_document_type     IN     VARCHAR2,
                                    p_document_subtype  IN     VARCHAR2,
                                    p_rebuild_code      IN     VARCHAR2 DEFAULT 'INITIAL_BUILD',
                                    p_return_code       OUT NOCOPY    NUMBER,
                                    p_error_stack       IN OUT NOCOPY ErrorStackType,
                                    p_approval_list     OUT NOCOPY    ApprovalListType,
                                    p_approver_id       IN     VARCHAR2 DEFAULT NULL);


-- Description: Retrieve the latest approval list needed at the time of
--              each approval.
--
-- Arguments:
--   In: p_document_id              ... header_id of new document
--       p_document_type            ... document type
--       p_document_subtype         ... document subtype
--  Out: p_return_code              ... E_SUCCESS
--                                        - operation is successful
--                                      others
--                                        - a sqlcode in case in case of sql errors
--       p_error_stack              ... a stack of error message codes and tokens
--       p_approval_list_header_id  ... approval list header id
--       p_last_update_date         ... last update date of the approval list tables
--                                      (for lock checking)
--       p_approval_list            ... latest approval list
--
-- Algorithm:
--   (1) Read from the approval list and delegation tables
--
PROCEDURE get_latest_approval_list(p_document_id             IN  NUMBER,
                                   p_document_type           IN  VARCHAR2,
                                   p_document_subtype        IN  VARCHAR2,
                                   p_return_code             OUT NOCOPY NUMBER,
                                   p_error_stack             OUT NOCOPY ErrorStackType,
                                   p_approval_list_header_id OUT NOCOPY NUMBER,
                                   p_last_update_date        OUT NOCOPY DATE,
                                   p_approval_list           OUT NOCOPY ApprovalListType);




-- Description: Save the approval list.
--
-- Arguments:
--      In: p_document_id              ... header_id of new document
--          p_document_type            ... document type
--          p_document_subtype         ... document subtype
--          p_first_approver_id        ... first approver id [optional]
--                                         If first approver id is passed when calling
--                                          get_default_approval_list(), should pass
--                                          the same first approver id here
--          p_approval_list            ... new approval list
--                                         From either get_default_approval_list() or
--                                          get_latest_approval_list()
--          p_last_update_date         ... last update date of approval list
--                                         If p_approval_list is obtained by calling
--                                          get_latest_approval_list(), pass the
--                                          corresponding p_last_update_date in one of
--                                          the out parameters
--                                         If p_approval_list is from get_default_
--                                          approval_list(), pass NULL
--  In Out: p_approval_list_header_id  ... approval list header id
--                                         If p_approval_list is from get_latest_
--                                          approval_list(), pass the corresponding
--                                          p_approval_list_header_id in one of the
--                                          out parameters.
--                                         If p_approval_list is from get_default_
--                                          approval_list(), pass NULL
--                                         In either case, it with contain the new
--                                          approval_list_header_id of the saved list
--                                          if operation is successful
--     Out: p_return_code              ... E_SUCCESS
--                                           - operation is successful
--                                         E_LIST_MODIFIED_SINCE_RETRIEVE
--                                           - approval list is modified since last
--                                             get_latest_approval_list()
--                                         E_INVALID_LIST_HEADER_ID
--                                           - the p_approval_list_header_id passed
--                                             is not valid
--                                         E_INVALID_APPROVAL_LIST
--                                           - p_approval_list is not valid
--                                         E_FAIL_TO_ACQUIRE_LOCK
--                                           - someone else is locking the approval
--                                             list tables
--                                         others
--                                           - a sqlcode in case in case of sql errors
--          p_error_stack              ... a stack of error message codes and tokens
--
-- Algorithm:
--
PROCEDURE save_approval_list(p_document_id             IN     NUMBER,
                             p_document_type           IN     VARCHAR2,
                             p_document_subtype        IN     VARCHAR2,
                             p_first_approver_id       IN     NUMBER,
                             p_approval_path_id        IN     NUMBER,
                             p_approval_list           IN     ApprovalListType,
                             p_last_update_date        IN     DATE,
                             p_approval_list_header_id IN OUT NOCOPY NUMBER,
                             p_return_code             OUT NOCOPY    NUMBER,
                             p_error_stack             OUT NOCOPY    ErrorStackType);


-- Description: Rebuild the existing approval list. (NOTE: a approval list must
--              exist, otherwise will return E_NO_APPROVAL_LIST_FOUND)
--
-- Arguments:
--   In: p_document_id              ... header_id of new document
--       p_document_type            ... document type
--       p_document_subtype         ... document subtype
--       p_rebuild_code             ... DOCUMENT_CHANGED - used by Req front end
--                                      FORWARD_RESPONSE - used by Workflow
--                                      INVALID_APPROVER - used by Workflow
--  Out: p_return_code              ... E_SUCCESS
--                                        - operation is successful
--                                      E_UNSUPPORTED_DOCUMENT_TYPE
--                                        - document type/subtype is not supported
--                                      E_NO_APPROVAL_LIST_FOUND
--                                        - could not find the associated approval
--                                          list
--                                      E_INVALID_FORWARD_TO_ID
--                                        - the most recent forward_to_id is not valid
--                                      E_DOCUMENT_ALREADY_PREAPPROVED
--                                        - the document is already preapproved so
--                                          no rebulid is needed
--                                      E_INVALID_APPROVAL_LIST
--                                        - approval list is invalid
--                                      E_LIST_MODIFIED_SINCE_RETRIEVE
--                                        - failed to lock the list tables
--                                      others
--                                        - a sqlcode in case in case of sql errors
--       p_error_stack              ... a stack of error message codes and tokens
--       p_approval_list_header_id  ... new approval_list_header_id as a result of
--                                      rebuild
--
-- Algorithm:
--
PROCEDURE rebuild_approval_list(p_document_id             IN  NUMBER,
                                p_document_type           IN  VARCHAR2,
                                p_document_subtype        IN  VARCHAR2,
                                p_rebuild_code            IN  VARCHAR2,
                                p_return_code             OUT NOCOPY NUMBER,
                                p_error_stack             OUT NOCOPY ErrorStackType,
                                p_approval_list_header_id OUT NOCOPY NUMBER);



-- Description: Validate the approval list.
--
-- Arguments:
--   In: p_document_id          ... header_id of new document
--       p_document_type        ... document type
--       p_document_subtype     ... document subtype
--       p_approval_list        ... new approval list
--       p_current_sequence_num ... the current sequence number [optional]
--  Out: p_return_code          ... E_SUCCESS
--                                   - operation is successful
--                                  E_INVALID_APPROVAL_LIST
--                                   - approval list is invalid
--                                  others
--                                   - a sqlcode in case in case of sql errors
--       p_error_stack          ... a stack of error message codes and tokens
--
-- Algorithm:
--  (1) Loop throught every approver on the approval list
--  (2) Check if approver is valid by calling is_approver_valid()
--
PROCEDURE validate_approval_list(p_document_id          IN     NUMBER,
                                 p_document_type        IN     VARCHAR2,
                                 p_document_subtype     IN     VARCHAR2,
                                 p_approval_list        IN     ApprovalListType,
                                 p_current_sequence_num IN     NUMBER,
                                 p_return_code          OUT NOCOPY    NUMBER,
                                 p_error_stack          IN OUT NOCOPY ErrorStackType);


-- Description: Determine whether or not an approver is valid.
--
-- Arguments:
--   In: p_document_id       ... header_id of new document
--       p_document_type     ... document type
--       p_document_subtype  ... document subtype
--       p_approver_id       ... employee_id of approver
--       p_approver_type     ... type of approver
--
-- Return:
--   TRUE  ... if the approver can be put on the approval list
--   FALSE ... otherwise
--
-- Algorithm:
--   (1) check if approver_type is valid
--   (2) check if approver is valid employee
--   (3) check if he/she is in wf_users
--
FUNCTION is_approver_valid(p_document_id      IN NUMBER,
                           p_document_type    IN VARCHAR2,
                           p_document_subtype IN VARCHAR2,
                           p_approver_id      IN NUMBER,
                           p_approver_type    IN VARCHAR2) return BOOLEAN;




-- Description: Determine whether or not an approver is mandatory
--
-- Arguments:
--   In: p_document_id       ... header_id of new document
--       p_document_type     ... document type
--       p_document_subtype  ... document subtype
--       p_preparer_id       ... employee_id of preparer
--       p_approver_id       ... employee_id of approver
--       p_approver_type     ... type of approver
--
-- Return:
--   TRUE  ... if the approver is mandatory
--   FALSE ... if not
--
-- Algorithm:
--   (1) If p_approver_type is system default, return TRUE
--       else return FALSE
--
FUNCTION is_approver_mandatory(p_document_id      IN NUMBER,
                               p_document_type    IN VARCHAR2,
                               p_document_subtype IN VARCHAR2,
                               p_preparer_id      IN NUMBER,
                               p_approver_id      IN NUMBER,
                               p_approver_type    IN VARCHAR2) RETURN BOOLEAN;



-- Procedures used by workflow

PROCEDURE get_next_approver(p_document_id      IN  NUMBER,
                            p_document_type    IN  VARCHAR2,
                            p_document_subtype IN  VARCHAR2,
                            p_return_code      OUT NOCOPY NUMBER,
                            p_next_approver_id OUT NOCOPY NUMBER,
                            p_sequence_num     OUT NOCOPY NUMBER,
                            p_approver_type    OUT NOCOPY VARCHAR2);

PROCEDURE does_approval_list_exist(p_document_id             IN  NUMBER,
                                   p_document_type           IN  VARCHAR2,
                                   p_document_subtype        IN  VARCHAR2,
                                   p_itemtype                IN  VARCHAR2,
                                   p_itemkey                 IN  VARCHAR2,
                                   p_return_code             OUT NOCOPY NUMBER,
                                   p_approval_list_header_id OUT NOCOPY NUMBER);

PROCEDURE update_approval_list_itemkey(p_approval_list_header_id IN  NUMBER,
                                       p_itemtype                IN  VARCHAR2,
                                       p_itemkey                 IN  VARCHAR2,
                                       p_return_code             OUT NOCOPY NUMBER);

PROCEDURE update_approval_list_response(p_document_id      IN  NUMBER,
                                        p_document_type    IN  VARCHAR2,
                                        p_document_subtype IN  VARCHAR2,
                                        p_itemtype         IN  VARCHAR2,
                                        p_itemkey          IN  VARCHAR2,
                                        p_approver_id      IN  NUMBER,
                                        p_responder_id     IN  NUMBER,
                                        p_forward_to_id    IN  NUMBER,
                                        p_response         IN  VARCHAR2,
                                        p_response_date    IN  DATE,
                                        p_comments         IN  VARCHAR2,
                                        p_return_code      OUT NOCOPY NUMBER);

PROCEDURE is_approval_list_exhausted(p_document_id      IN  VARCHAR2,
                                     p_document_type    IN  VARCHAR2,
                                     p_document_subtype IN  VARCHAR2,
                                     p_itemtype         IN  VARCHAR2,
                                     p_itemkey          IN  VARCHAR2,
                                     p_return_code      OUT NOCOPY NUMBER,
                                     p_result           OUT NOCOPY BOOLEAN);

PROCEDURE print_approval_list(p_approval_list IN ApprovalListType);

PROCEDURE retrieve_messages(p_error_stack   IN  ErrorStackType,
                            p_return_code   OUT NOCOPY NUMBER,
                            p_message_stack OUT NOCOPY MessageStackType);

PROCEDURE print_error_stack(p_error_stack IN ErrorStackType);

PROCEDURE forms_rebuild_approval_list(p_document_id             IN  NUMBER,
                                      p_document_type           IN  VARCHAR2,
                                      p_document_subtype        IN  VARCHAR2,
                                      p_rebuild_code            IN  VARCHAR2,
                                      p_return_code             OUT NOCOPY NUMBER,
                                      p_approval_list_header_id OUT NOCOPY NUMBER);


END PO_APPROVALLIST_S1;


/
