class String {
public:
    String(char const *str, int length, int capacity) {
        this->str = str;
        this->length = length;
        this->capacity = capacity;
    }

    String() {
        this->str = "";
        this->length = 0;
        this->capacity = 0;
    }

    char const *str;
    int length;
    int capacity;
};
