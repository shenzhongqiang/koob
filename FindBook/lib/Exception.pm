package Exception;
use Exception::Class (
    'RequestError' => {
        fields => ['url'],
    },
    'BookAlreadyExists' => {
        fields => ['isbn'],
    },
    'TagAlreadyExists' => {
        fields => ['catalog', 'subcat'],
    },
    'IsbnNotExists' => {
        fields => [],
    },
    'NoDescription' => {
        fields => [],
    },
    'NoValidPic' => {
        fields => [],
    },
    'InBlacklist' => {
        fields => [],
    },
);

1;
