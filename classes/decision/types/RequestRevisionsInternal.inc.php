<?php
/**
 * @file classes/decision/types/RequestRevisionsInternal.inc.php
 *
 * Copyright (c) 2014-2022 Simon Fraser University
 * Copyright (c) 2000-2022 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class decision
 *
 * @brief A decision to request revisions during an internal review round
 */

namespace APP\decision\types;

use APP\decision\Decision;
use APP\decision\types\traits\InInternalReviewRound;
use PKP\decision\types\RequestRevisions;

class RequestRevisionsInternal extends RequestRevisions
{
    use InInternalReviewRound;

    public function getDecision(): int
    {
        return Decision::PENDING_REVISIONS_INTERNAL;
    }
}
