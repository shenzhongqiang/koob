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
);

1;
