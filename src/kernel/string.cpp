class String {
public:
    String(char const *str, int length, int capacity) {
        this->str = str;
        this->length = length;
        this->capacity = capacity;
    }

    char const *str;
    int length;
    int capacity;
};
